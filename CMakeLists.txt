cmake_minimum_required(VERSION 3.16)

project(MusicPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/myapp.rc")

find_package(Qt6 REQUIRED COMPONENTS Quick core QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appMusicPlayer
    main.cpp
    ${app_icon_resource_windows}
    resourcesimages.qrc
)

qt_add_qml_module(appMusicPlayer
    URI MusicPlayer
    VERSION 1.0
    QML_FILES
        Main.qml
        qml/MusicList.qml
        qml/FunctionList.qml
        qml/MediaButton.qml
        qml/MusicLrc.qml
        qml/SearchMusic.qml
    RESOURCES
        qml/image/new.png
        qml/image/last.png qml/image/next.png qml/image/play.png qml/image/stop.png
        qml/image/circle.png qml/image/order.png qml/image/random.png
        qml/image/file.png
        qml/image/openfile.png
        qml/image/dele.png
        qml/image/search.png
    SOURCES
        cpp/getlyrics.h cpp/getlyrics.cpp
        cpp/lyricsmodel.h cpp/lyricsmodel.cpp
        cpp/search.h cpp/search.cpp
        cpp/nodemanager.h cpp/nodemanager.cpp
        cpp/searchmodel.h cpp/searchmodel.cpp
)
target_include_directories(appMusicPlayer PRIVATE cpp)
# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMusicPlayer PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMusicPlayer
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMusicPlayer
    PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::QuickControls2
)
target_link_libraries(appMusicPlayer PRIVATE Qt6::Core)

include(GNUInstallDirs)
install(TARGETS appMusicPlayer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
