#include "searchmodel.h"

void SearchModel::setListData(const QList<datalist> &newData)
{
    // 开始重置模型 - 通知视图数据将要改变
    beginResetModel();
    // 更新数据
    list = newData;
    // 结束重置模型 - 通知视图数据已经改变
    endResetModel();
}

void SearchModel::clearData()
{
    beginResetModel();
    list.clear();
    endResetModel();
}

SearchModel::SearchModel(QObject *parent)
    : QAbstractListModel{parent}
{}

int SearchModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return list.size();
}

QVariant SearchModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= list.size())
        return QVariant();
    const auto &item = list.value(index.row());

    switch(role){
    case titleRole:
        return item.title;
    case artistRole:
        return item.artist;
    case artworkRole:
        return item.artwork;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> SearchModel::roleNames() const
{
    return {
        {titleRole, "title"},
        {artistRole, "artist"},
        {artworkRole,"artwork"}
    };
}
