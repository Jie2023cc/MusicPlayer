#ifndef LYRICSMODEL_H
#define LYRICSMODEL_H

#include <QObject>
#include <QAbstractListModel>

class LyricsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum MusicRoles {
        IndexRole = Qt::UserRole + 1,
        LyricsOneRole,
        LyricsTwoRole
    };
    explicit LyricsModel(QObject *parent = nullptr);
    Q_INVOKABLE void setMusicData(const QMap<qint64, QStringList> &newData);
    Q_INVOKABLE void setKeys(const QList<qint64> &newData);
    Q_INVOKABLE void clearData();

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
signals:
private:
    QMap<qint64, QStringList> lyrics{};
    QList<qint64> timeKeys{};
};

#endif // LYRICSMODEL_H
