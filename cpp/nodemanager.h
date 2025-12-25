#ifndef NODEMANAGER_H
#define NODEMANAGER_H

#include <QObject>
#include <QProcess>

class NodeManager : public QObject
{
    Q_OBJECT
public:
    static NodeManager* instance();

    void start();
    void stop();
    bool isRunning() const;

private:
    explicit NodeManager(QObject *parent = nullptr);
    ~NodeManager();

    static NodeManager *m_instance;
    QProcess* m_process;
signals:
};

#endif // NODEMANAGER_H
