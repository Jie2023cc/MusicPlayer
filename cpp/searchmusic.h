#ifndef SEARCHMUSIC_H
#define SEARCHMUSIC_H

#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>
#include <qDebug>
class SearchMusicCpp : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE void searchmusic(QString keyword);
    explicit SearchMusicCpp(QObject *parent = nullptr);

signals:
};

#endif // SEARCHMUSIC_H
