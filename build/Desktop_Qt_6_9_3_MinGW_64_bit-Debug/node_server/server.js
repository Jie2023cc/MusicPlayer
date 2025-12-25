const express = require('express');
const musicAPI = require('musicfree-api');
const app = express();
const port = 3000;

// 允许Qt应用跨域访问（重要！）
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    next();
});

app.get('/', (req, res) => {
    res.send('Music API Server is running');
});

// 定义搜索接口：你的Qt应用将来就请求这个地址
app.get('/search', async (req, res) => {
    let timeoutId;
    try {
        console.log('收到搜索请求，关键词：', req.query.keyword);

        // 1. 创建一个会在5秒后拒绝的Promise作为超时器
        const timeoutPromise = new Promise((_, reject) => {
            timeoutId = setTimeout(() => {
                reject(new Error('musicfree-api 请求超时（超过5000毫秒），可能在安卓环境不兼容或网络失败'));
            }, 5000);
        });

        // 2. 创建实际的搜索请求Promise
        const searchPromise = musicAPI.search('qq', req.query.keyword, 1, 'music');

        // 3. 让它们“竞速”：谁先完成就用谁的结果
        const result = await Promise.race([searchPromise, timeoutPromise]);

        // 4. 如果搜索成功，清除超时定时器
        clearTimeout(timeoutId);

        res.json({
            success: true,
            data: result.data
        });

    } catch (error) {
        // 确保超时定时器被清理
        if (timeoutId) clearTimeout(timeoutId);
        console.error('搜索出错:', error);
        // 将详细的错误信息返回，方便调试
        res.json({
            success: false,
            message: error.message,
            // 可以额外返回一个标记，方便前端判断
            errorType: 'API_REQUEST_FAILED'
        });
    }
});

// ========== 新增：获取歌曲播放地址接口 ==========
app.get('/songUrl', async (req, res) => {
    try {
        console.log('收到获取播放地址请求：', req.query);

        // 1. 从请求中获取参数
        const platform = req.query.platform || 'qq'; // 音乐平台，默认为QQ音乐
        const song = JSON.parse(req.query.song); // 歌曲信息对象（从搜索结果的歌曲对象获得）
        const quality = req.query.quality || 'high'; // 音质：low, standard, high, super

        // 2. 调用 musicfree-api 获取媒体源（播放地址）
        const mediaSource = await musicAPI.getMediaSource(platform, song, quality);

        // 3. 将播放地址等信息返回给Qt应用
        res.json({
            success: true,
            source: platform,
            quality: quality,
            // 最重要的播放/下载链接就在这里
            url: mediaSource.url,
            // 有时会返回多种格式的链接或额外信息
            rawData: mediaSource
        });

    } catch (error) {
        console.error('获取播放地址出错:', error);
        res.json({
            success: false,
            message: error.message
        });
    }
});
// Node.js 服务端添加歌词接口
app.get('/lyric', async (req, res) => {
    try {
        console.log('收到获取歌词请求：', req.query);

        const platform = req.query.platform || 'qq';
        const song = JSON.parse(req.query.song);

        // 假设 musicfree-api 有获取歌词的方法
        const lyric = await musicAPI.getLyric(platform, song);

        res.json({
            success: true,
            source: platform,
            lyric: lyric
        });

    } catch (error) {
        console.error('获取歌词出错:', error);
        res.json({
            success: false,
            message: error.message
        });
    }
});

// 启动服务器
app.listen(port, '0.0.0.0', () => {
    console.log(`✅ 音乐数据服务已启动！`);
    console.log(`✅ 服务地址：http://0.0.0.0:${port}`);
    console.log(`✅ 在手机内访问：http://127.0.0.1:${port}/search?keyword=周杰伦`);
});
