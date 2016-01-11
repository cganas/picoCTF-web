var gulp = require("gulp");
var uglify = require("gulp-uglify");
var htmlreplace = require("gulp-html-replace");
var source = require("vinyl-source-stream");
var browserify = require("browserify");
var watchify = require("watchify");
var cjsx = require("gulp-cjsx");
var streamify = require("gulp-streamify");

var path = {
    HTML: "public/index.html",
    MINIFIED_OUT: "build.min.js",
    OUT: "build.js",
    CJSX_SRC: "src/**/*.cjsx",
    DEST: "/srv/http/ctf",
    DEST_BUILD: "/srv/http/ctf",
    DEST_SRC: "/srv/http/ctf",
    ENTRY_POINT: "./dist/src/app_router.js"
};

gulp.task("copy", function(){
    gulp.src("public/**/*")
        .pipe(gulp.dest(path.DEST));
});

gulp.task("watch", function() {
    gulp.watch(path.HTML, ["copy"]);
    gulp.watch(path.CJSX_SRC, ["cjsx"]);

    var watcher  = watchify(browserify({
        entries: [path.ENTRY_POINT],
        debug: true,
        cache: {}, packageCache: {}, fullPaths: true
    }));

    return watcher.on("update", function () {
        watcher.bundle()
            .pipe(source(path.OUT))
            .pipe(gulp.dest(path.DEST_SRC));
    })
        .bundle()
        .pipe(source(path.OUT))
        .pipe(gulp.dest(path.DEST_SRC));
});

gulp.task("default", ["watch"]);

gulp.task("cjsx", function() {
    gulp.src(path.CJSX_SRC)
        .pipe(cjsx({bare: true}).on("error", console.log))
        .pipe(gulp.dest(path.DEST_SRC));
});

gulp.task("build", function(){
    browserify({entries: [path.ENTRY_POINT]})
        .bundle()
        .pipe(source(path.MINIFIED_OUT))
        .pipe(gulp.dest(path.DEST_BUILD));
});

gulp.task("replaceHTML", function(){
    gulp.src(path.HTML)
        .pipe(htmlreplace({
            "js": "build/" + path.MINIFIED_OUT
        }))
        .pipe(gulp.dest(path.DEST));
});

gulp.task("production", ["replaceHTML", "cjsx", "build"]);
