gulp   = require 'gulp'
cjsx   = require 'gulp-cjsx'
gutil  = require 'gulp-util'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
minifyCss = require 'gulp-minify-css'

gulp.task "copy", ->
    gulp.src("public/**/*")
        .pipe(gulp.dest("./dist"))

gulp.task 'watch', ->
  gulp.watch ['./public/**/*'], ['copy']
  gulp.watch ['./public/css/**/*.css'], ['minify-css']
  gulp.watch ['./src/**/*.cjsx'], ['cjsx', 'build']

gulp.task 'cjsx', ->
  gulp.src './src/**/*.cjsx'
  .pipe cjsx
    bare: true
  .on 'error', gutil.log
  .pipe gulp.dest('./dist/src/')

gulp.task 'minify-css', ->
  gulp.src('src/css/*.css')
  .pipe minifyCss(compatibility: 'ie8')
  .pipe gulp.dest('./dist/public/css/')

gulp.task 'build', ["cjsx"], ->
  browserify
    entries: ['./dist/src/app_router.js']
    extensions: ['.js']
  .bundle()
  .pipe source 'build.js'
  .pipe gulp.dest './dist/src'

gulp.task 'default', ["copy", 'build', 'minify-css']
