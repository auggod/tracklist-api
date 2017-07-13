gulp = require('gulp')
gulpLiveScript = require('gulp-livescript')

gulp.task 'ls', ->
  gulp.src('./*.ls').pipe(gulpLiveScript(bare: true)).pipe gulp.dest('.')

gulp.task 'watch', ->
  gulp.watch './', [ 'ls' ]

# Default Task
gulp.task 'default', [
  'ls'
  'watch'
]
