#ifndef GETLYRICS_H
#define GETLYRICS_H

#include <QObject>
#include <qDebug>
#include <QFile>
#include <QUrl>
#include <QRegularExpression>
#include <QtQmlIntegration/qqmlintegration.h>
#include "LyricsModel.h"
class GetLyrics : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(LyricsModel* musicModel READ musicModel CONSTANT)
public:
    Q_INVOKABLE void getUrl(QString url);
    Q_INVOKABLE qint64 returnIndex(qint64 time,qint64 index);
    explicit GetLyrics(QObject *parent = nullptr);
    LyricsModel* musicModel() const;
signals:

private:
    LyricsModel *m_Model{nullptr};
    QList<qint64> m_timeKeys{};
    QMap<qint64, QStringList> m_lyrics{};
    QRegularExpression m_fileUrl{"\\.(mp3|aac|wav)$",QRegularExpression::CaseInsensitiveOption};
    QRegularExpression m_lyricsTime{"\\[(\\d{2}):(\\d{2})\\.(\\d{2})\\](.*)"};
};

#endif // GETLYRICS_H
