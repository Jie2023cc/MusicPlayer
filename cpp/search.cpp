#include "search.h"
#include <QDir>
#include <QFileInfo>
#include <QSharedPointer>

void Search::getkeyword(QString keyword)
{
    m_list.clear();
    m_model->clearData();
    if(!NodeManager::instance()->isRunning()){
        NodeManager::instance()->start();
    }
    QNetworkRequest req(QUrl("http://127.0.0.1:3000/search?keyword="+keyword));
    QNetworkReply *r = manager->get(req);
    QObject::connect(r, &QNetworkReply::finished,this, [this, r]() {
        if (r->error() == QNetworkReply::NoError) {
            QByteArray data = r->readAll();
            qDebug() << "✅ 响应:" << data.length() << "字节";
            QJsonDocument doc = QJsonDocument::fromJson(data);
            QJsonObject rootObj = doc.object();
            QJsonArray dataArray = rootObj["data"].toArray();
            for (const QJsonValue &value : dataArray) {
                QJsonObject songObj = value.toObject();
                m_list.append({
                    songObj["id"].toInt(),
                    songObj["songmid"].toString(),
                    songObj["title"].toString(),
                    songObj["artist"].toString(),
                    songObj["artwork"].toString(),
                    songObj["album"].toString(),
                    songObj["albumid"].toInt(),
                    songObj["albummid"].toString()
                });
            }
            m_model->setListData(m_list);
        } else {
            qDebug() << "搜索网络错误:" << r->errorString();
        }
        r->deleteLater();
    });
}

void Search::geturl(int index)
{
    if (index < 0 || index >= m_list.size()) {
        qDebug() << "索引超出范围";
        return;
    }
    if(!NodeManager::instance()->isRunning()){
        NodeManager::instance()->start();
    }
    QJsonDocument doc({
        {"id", m_list[index].id},
        {"songmid", m_list[index].songmid},
        {"title", m_list[index].title},
        {"artist", m_list[index].artist},
        {"artwork", m_list[index].artwork},
        {"album", m_list[index].album},
        {"albumid", m_list[index].albumid},
        {"albummid", m_list[index].albummid}
    });
    // 先转换为JSON字符串
    QString jsonStr = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));
    // 使用 QUrl::toPercentEncoding() 进行URL编码
    QString encodedJson = QUrl::toPercentEncoding(jsonStr);
    QString urlStr = QString("http://127.0.0.1:3000/songUrl?"
                             "platform=qq&"
                             "quality=high&"
                             "song=%1").arg(encodedJson);

    // 发送请求
    QUrl url(urlStr);
    QNetworkReply *r = manager->get(QNetworkRequest(url));
    QObject::connect(r, &QNetworkReply::finished, [this, r]() {
        if (r->error() == QNetworkReply::NoError) {
            QByteArray data = r->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(data);
            QJsonObject obj = doc.object();
            if (obj["success"].toBool()) {
                QString url = obj["url"].toString();
                emit playurl(url);
            } else {
                qDebug() << "获取播放地址失败:" << obj["message"].toString();
            }
        } else {
            qDebug() << "网络错误:" << r->errorString();
        }
        r->deleteLater();
    });
}

QString Search::downmusic(int index, QString downurl, QString downfile)
{
    if (index < 0 || index >= m_list.size()) {
        qDebug() << "索引超出范围";
        return "";
    }

    // 规范化传入的 downfile（支持 file:// URL 或直接路径）
    QString localDest = downfile;
    QUrl maybeUrl(downfile);
    if (maybeUrl.isValid() && (maybeUrl.isLocalFile() || maybeUrl.scheme() == "file")) {
        localDest = maybeUrl.toLocalFile();
    }
    if (localDest.isEmpty()) localDest = QDir::currentPath();

    QFileInfo destInfo(localDest);
    QString finalFilePath;

    // 如果传入的是一个已经存在的目录 => 把文件放在该目录
    if (destInfo.exists() && destInfo.isDir()) {
        finalFilePath = QDir(destInfo.absoluteFilePath()).filePath(m_list.at(index).title + ".mp3");
    }
    // 如果传入路径看起来像文件（有扩展名），把它当作完整文件路径
    else if (!destInfo.suffix().isEmpty()) {
        finalFilePath = destInfo.absoluteFilePath();
    }
    // 否则把传入值当作目录路径（即使它不存在），创建目录并放入文件
    else {
        QDir dir(localDest);
        if (!dir.exists()) {
            if (!dir.mkpath(".")) {
                qDebug() << "无法创建目录:" << localDest;
                emit downloadFinished(QString(), false, "无法创建目录");
                return "";
            }
        }
        finalFilePath = dir.filePath(m_list.at(index).title + ".mp3");
    }

    // 确保父目录存在
    QFileInfo finalFi(finalFilePath);
    if (!finalFi.dir().exists()) {
        if (!finalFi.dir().mkpath(".")) {
            qDebug() << "无法创建父目录:" << finalFi.dir().path();
            emit downloadFinished(finalFilePath, false, "无法创建父目录");
            return "";
        }
    }

    // 先准备歌词文件路径并异步下载歌词
    QString lyricspath = finalFi.dir().filePath(m_list.at(index).title + ".lrc");
    QString jpgspath = finalFi.dir().filePath(m_list.at(index).title + ".jpg");
    getjpg(m_list.at(index).artwork,jpgspath);
    getlyrics(index, lyricspath);
    QUrl qurl(downurl);
    QNetworkRequest req(qurl);
    QNetworkReply *r = manager->get(req);

    QFile *file = new QFile(finalFilePath);
    if (!file->open(QIODevice::WriteOnly)) {
        qDebug() << "无法创建文件:" << finalFilePath;
        delete file;
        r->deleteLater();
        emit downloadFinished(finalFilePath, false, "无法创建文件");
        return "";
    }

    // 下载进度
    QObject::connect(r, &QNetworkReply::downloadProgress, this, [r](qint64 received, qint64 total) {
        Q_UNUSED(r);
    });

    // 用共享指针保存前128字节，避免捕获局部变量引用导致的 use-after-free
    auto headBuf = QSharedPointer<QByteArray>::create();
    QObject::connect(r, &QNetworkReply::readyRead, this, [r, file, headBuf]() {
        QByteArray chunk = r->readAll();
        if (headBuf->size() < 128) {
            int need = 128 - headBuf->size();
            headBuf->append(chunk.left(need));
        }
        file->write(chunk);
    });

    QObject::connect(r, &QNetworkReply::finished, this, [this, r, file, headBuf]() {
        file->write(r->readAll());
        file->close();

        QVariant ct = r->header(QNetworkRequest::ContentTypeHeader);

        if (r->error() != QNetworkReply::NoError) {
            qDebug() << "下载失败：" << r->errorString();
            QFile::remove(file->fileName());
            emit downloadFinished(file->fileName(), false, r->errorString());
        } else {
            QByteArray head = *headBuf;
            if (head.isEmpty()) {
                QFile f(file->fileName());
                if (f.open(QIODevice::ReadOnly)) {
                    head = f.read(128);
                    f.close();
                }
            }
            emit downloadFinished(file->fileName(), true, QString());
        }
        delete file;
        r->deleteLater();
    });
    return jpgspath;
}

void Search::getlyrics(int index,QString filename)
{
    if (index < 0 || index >= m_list.size()) {
        return;
    }
    // 构建请求URL
    QString urlStr = QString("http://127.0.0.1:3000/lyric?"
                             "platform=qq&"
                             "song=%1").arg(
        QUrl::toPercentEncoding(
            QString::fromUtf8(
                QJsonDocument({
                       {"id", m_list[index].id},
                       {"songmid", m_list[index].songmid},
                       {"title", m_list[index].title},
                       {"artist", m_list[index].artist}
                    }).toJson(QJsonDocument::Compact)
                )
            )
        );
    QUrl qurl(urlStr);
    QNetworkRequest req(qurl);
    QNetworkReply *r = manager->get(req);

    // 处理输出文件名: 支持 file:// 或本地路径
    QString outFilename = filename;
    QUrl maybeFileUrl(filename);
    if (maybeFileUrl.isLocalFile() || maybeFileUrl.scheme() == "file") {
        outFilename = maybeFileUrl.toLocalFile();
    }
    if (outFilename.isEmpty()) {
        outFilename = QDir::current().filePath(m_list.at(index).title + ".lrc");
    }
    QFileInfo fi(outFilename);
    if (!fi.dir().exists()) fi.dir().mkpath(".");

    QObject::connect(r, &QNetworkReply::finished, [this,r,outFilename]() {
        QVariant ct = r->header(QNetworkRequest::ContentTypeHeader);
        if (r->error() == QNetworkReply::NoError) {
            QByteArray data = r->readAll();
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(data, &err);
            if (err.error != QJsonParseError::NoError) {
                qDebug() << "解析 JSON 失败:" << err.errorString();
                emit lyricSaved(outFilename, false, QStringLiteral("无效的 JSON 响应"));
                r->deleteLater();
                return;
            }
            QJsonObject obj = doc.object();
            if (obj["success"].toBool()) {
                QJsonObject lyricObj = obj["lyric"].toObject();
                QString lyric = lyricObj["rawLrc"].toString();
                if (lyric.isEmpty()) {
                    qDebug() << "歌词字段为空";
                    emit lyricSaved(outFilename, false, QStringLiteral("歌词内容为空"));
                    r->deleteLater();
                    return;
                }
                QFile file(outFilename);
                if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
                    file.write(lyric.toUtf8());
                    file.close();
                    emit lyricSaved(outFilename, true, QString());
                } else {
                    qDebug() << "无法保存歌词:" << outFilename;
                    emit lyricSaved(outFilename, false, "无法打开文件");
                }
            } else {
                qDebug() << "获取歌词失败:" << obj["message"].toString();
                emit lyricSaved(outFilename, false, obj["message"].toString());
            }
        } else {
            qDebug() << "网络错误:" << r->errorString();
            emit lyricSaved(outFilename, false, r->errorString());
        }
        r->deleteLater();
    });
}

void Search::getjpg(QString downurl, QString downfile)
{
    QUrl urljpg(downurl);
    QNetworkRequest req(urljpg);
    QNetworkReply *s = manager->get(req);
    QObject::connect(s, &QNetworkReply::finished, [this,s,downfile]() {
        QVariant ct = s->header(QNetworkRequest::ContentTypeHeader);
        if (s->error() == QNetworkReply::NoError) {
            QByteArray data = s->readAll();
            // 保存到文件
            QFile file(downfile);
            if (file.open(QIODevice::WriteOnly)) {
                file.write(data);
                file.close();
            } else {
                qDebug() << "❌ 无法保存文件:" << file.errorString();
            }
        }
        s->deleteLater();
    });
}

Search::Search(QObject *parent)
    : QObject{parent}
    ,manager(new QNetworkAccessManager(this))
    ,m_model(new SearchModel(this))
{
    m_list.reserve(30);
}

Search::~Search()
{
    NodeManager::instance()->stop();
}

SearchModel *Search::model() const
{
    return m_model;
}

