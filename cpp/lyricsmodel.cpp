#include "lyricsmodel.h"

LyricsModel::LyricsModel(QObject *parent)
    : QAbstractListModel{parent}
{}

void LyricsModel::setMusicData(const QMap<qint64, QStringList> &newData)
{
    // 开始重置模型 - 通知视图数据将要改变
    beginResetModel();
    // 更新数据
    lyrics = newData;
    // 结束重置模型 - 通知视图数据已经改变
    endResetModel();
}

void LyricsModel::setKeys(const QList<qint64> &newData)
{
    // 开始重置模型 - 通知视图数据将要改变
    beginResetModel();
    // 更新数据
    timeKeys = newData;
    // 结束重置模型 - 通知视图数据已经改变
    endResetModel();
}

void LyricsModel::clearData()
{
    beginResetModel();
    lyrics.clear();
    timeKeys.clear();
    endResetModel();
}

int LyricsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return lyrics.size();
}

QVariant LyricsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= lyrics.size())
        return QVariant();
    qint64 timeMs = timeKeys.at(index.row());
    const auto &item = lyrics.value(timeMs);

    switch(role){
    case IndexRole:
        return timeMs;
    case LyricsOneRole:
        if (!item.isEmpty()) {
            return item.first();
        };
    case LyricsTwoRole:
        if (item.size() > 1) {
            return item.at(1);
        };
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LyricsModel::roleNames() const
{
    return {
        {IndexRole, "indexLyrics"},
        {LyricsOneRole, "oneLyrics"},
        {LyricsTwoRole,"twoLyrics"}
    };
}
