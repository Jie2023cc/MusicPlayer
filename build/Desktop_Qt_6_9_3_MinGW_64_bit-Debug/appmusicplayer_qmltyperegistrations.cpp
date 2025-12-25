/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#if __has_include(<getlyrics.h>)
#  include <getlyrics.h>
#endif
#if __has_include(<search.h>)
#  include <search.h>
#endif


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_MusicPlayer()
{
    QT_WARNING_PUSH QT_WARNING_DISABLE_DEPRECATED
    qmlRegisterTypesAndRevisions<GetLyrics>("MusicPlayer", 1);
    qmlRegisterTypesAndRevisions<Search>("MusicPlayer", 1);
    QT_WARNING_POP
    qmlRegisterModule("MusicPlayer", 1, 0);
}

static const QQmlModuleRegistration musicPlayerRegistration("MusicPlayer", qml_register_types_MusicPlayer);
