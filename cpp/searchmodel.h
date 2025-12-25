#ifndef SEARCHMODEL_H
#define SEARCHMODEL_H

#include <QObject>
#include <QAbstractListModel>
struct datalist
{
    int id;
    QString songmid;
    QString title;
    QString artist;
    QString artwork;
    QString album;
    int albumid;
    QString albummid;
    datalist(int id = 0,
         const QString &songmid = "",
         const QString &title = "",
         const QString &artist = "",
         const QString &artwork = "",
         const QString &album = "",
         int albumid = 0,
         const QString &albummid = "")
        : id(id), songmid(songmid), title(title), artist(artist),
        artwork(artwork), album(album), albumid(albumid), albummid(albummid) {}
};

class SearchModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ListRoles {
        titleRole = Qt::UserRole + 1,
        artistRole,
        artworkRole,
    };

    Q_INVOKABLE void setListData(const QList<datalist> &newData);
    Q_INVOKABLE void clearData();
    explicit SearchModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<datalist> list{};
signals:

};

#endif // SEARCHMODEL_H
