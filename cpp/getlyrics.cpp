#include "getlyrics.h"

GetLyrics::GetLyrics(QObject *parent)
    : QObject{parent}
    , m_Model(new LyricsModel(this))
{}

LyricsModel *GetLyrics::musicModel() const
{
    return m_Model;
}

void GetLyrics::getUrl(QString url)
{
    m_lyrics.clear();
    m_timeKeys.clear();
    m_Model->clearData();
    QUrl fileUrl(url.replace(m_fileUrl, ".lrc"));
    QString localPath = fileUrl.toLocalFile();
    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开歌词文件:" << file.errorString();
        return;
    }
    QTextStream stream(&file);
    stream.setEncoding(QStringConverter::Utf8);
    while (!stream.atEnd()) {
        QString line = stream.readLine().trimmed();
        QRegularExpressionMatch match = m_lyricsTime.match(line);
        if (match.hasMatch()) {
            int minutes = match.captured(1).toInt();
            int seconds = match.captured(2).toInt();
            QString text = match.captured(4).trimmed();
            qint64 totalMs = (minutes * 60 + seconds) ;
            if (!m_lyrics.contains(totalMs)) {
                m_timeKeys.append(totalMs);
                m_lyrics[totalMs] = QStringList();
            }
            m_lyrics[totalMs].append(text);
        }
    }
    for (auto it = m_lyrics.begin(); it != m_lyrics.end(); ) {
        bool allEmpty = true;
        const QStringList &list = it.value();
        for (const QString &str : list) {
            if (!str.trimmed().isEmpty()) {
                allEmpty = false;
                break;
            }
        }
        if (allEmpty) {
            it = m_lyrics.erase(it);
        } else {
            ++it;
        }
    }
    for (auto it = m_lyrics.begin(); it != m_lyrics.end(); ++it) {
        QStringList &list = it.value();
        if (list.size() >= 2) {
            std::swap(list[0], list[1]);
        }
    }
    m_Model->setKeys(m_timeKeys);
    m_Model->setMusicData(m_lyrics);
    file.close();
}

qint64 GetLyrics::returnIndex(qint64 time,qint64 index)
{
    if(m_timeKeys.contains(time)){
        return m_timeKeys.indexOf(time);
    }else{
        return index;
    }
}

