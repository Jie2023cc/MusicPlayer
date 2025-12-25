#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QDir>
#include <QQmlContext>
#include "NodeManager.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    NodeManager::instance()->start();
    app.setOrganizationName("MyCompany");
    app.setOrganizationDomain("mycompany.com");
    app.setApplicationName("MyApp");
    QQuickStyle::setStyle("Basic");
    QQmlApplicationEngine engine;
    QString appDirPath = QDir::fromNativeSeparators(QCoreApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("path",appDirPath);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("MusicPlayer", "Main");
    int result = app.exec();
    NodeManager::instance()->stop();
    return result;
}
