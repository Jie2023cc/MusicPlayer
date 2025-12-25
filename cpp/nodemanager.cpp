#include "nodemanager.h"
#include <QCoreApplication>
#include <QDir>
NodeManager* NodeManager::m_instance = nullptr;
NodeManager *NodeManager::instance()
{
    if (!m_instance) {
        m_instance = new NodeManager();
    }
    return m_instance;
}

void NodeManager::start()
{
    if (m_process && m_process->state() == QProcess::Running) {
        return;
    }

    if (!m_process) {
        m_process = new QProcess(this);
    }


    // QString appDir = QCoreApplication::applicationDirPath();
    // QDir appDirDir(appDir);
    // QString nodeProgram = appDirDir.filePath("runtime/node.exe");
    // QString serverScript = appDirDir.filePath("node_server/server.js");
    // m_process->setWorkingDirectory(appDirDir.filePath("node_server")); // 工作目录设为后端目录
    // m_process->start(nodeProgram, {serverScript});

    m_process->start("node", {"node_server/server.js"});
    m_process->waitForStarted(3000);
}

void NodeManager::stop()
{
    if (m_process && m_process->state() == QProcess::Running) {
        m_process->terminate();
        m_process->waitForFinished(2000);
    }
}

bool NodeManager::isRunning() const
{
    return m_process && m_process->state() == QProcess::Running;
}

NodeManager::NodeManager(QObject *parent)
    : QObject{parent}
{}

NodeManager::~NodeManager()
{
    stop();
}
