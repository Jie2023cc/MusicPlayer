#ifndef SEARCH_H
#define SEARCH_H
#include <QObject>
#include <qDebug>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QtQmlIntegration/qqmlintegration.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "SearchModel.h"
#include "NodeManager.h"
class Search : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(SearchModel *model READ model CONSTANT)
public:
    Q_INVOKABLE void getkeyword(QString keyword);
    Q_INVOKABLE void geturl(int index);
    Q_INVOKABLE QString downmusic(int index,QString downurl,QString downfile);
    Q_INVOKABLE void getlyrics(int index,QString filename);
    Q_INVOKABLE void getjpg(QString downurl,QString downfile);
    explicit Search(QObject *parent = nullptr);
    ~Search();

    SearchModel *model() const;

private:
    QList<datalist> m_list{};
    QNetworkAccessManager *manager;
    QNetworkReply *reply{nullptr};
    SearchModel *m_model;

signals:
    void playurl(QString url);
    void downloadFinished(QString path, bool success, QString error);
    void lyricSaved(QString path, bool success, QString error);
};

#endif // SEARCH_H
