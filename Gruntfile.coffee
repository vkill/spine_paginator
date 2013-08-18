module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    meta:
      banner:
        '// spine.paginator.js\n' +
        '// version: <%= pkg.version %>\n' +
        '// author: <%= pkg.author %>\n' +
        '// license: <%= pkg.licenses[0].type %>\n'

    coffee:
      all:
        files:
          'dist/spine.paginator.js': 'src/spine.paginator.coffee'
          'dist/spine.pagination_controller.js': 'src/spine.pagination_controller.coffee'
          'examples/spine_pagination.js': 'examples/spine_pagination.coffee'

    concat:
      all:
        options:
          banner: '<%= meta.banner %>'
        files:
          'dist/spine.paginator.js': 'dist/spine.paginator.js'
          'dist/spine.pagination_controller.js': 'dist/spine.pagination_controller.js'
          
    uglify:
      all:
        options:
          banner: '<%= meta.banner %>'
          report: 'gzip'
        files:
          'dist/spine.paginator.min.js': 'dist/spine.paginator.js'
          'dist/spine.pagination_controller.min.js': 'dist/spine.pagination_controller.js'
    
    copy:
      main:
        files: [
          {expand: true, flatten: true, src: ['dist/**'], dest: 'vendor/assets/javascripts/'}
        ]

    jasmine:
      all:
        src: 'dist/*.js'
        options:
          specs: 'spec/spine.paginator/**/*.js'
          helpers: 'spec/lib/**/*.js'
    
    slim:
      all:
        files:
          'examples/spine_pagination.html': 'examples/spine_pagination.slim'
    sass:
      all:
        files:
          'examples/spine_pagination.css': 'examples/spine_pagination.scss'

    watch:
      all:
        files: ['src/*.coffee', 'examples/*.coffee', 'examples/*.slim', 'examples/*.scss']
        tasks: ['build', 'spec']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-slim'
  grunt.loadNpmTasks 'grunt-contrib-sass'

  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'spec',    ['jasmine']
  grunt.registerTask 'build',   ['coffee', 'concat', 'uglify', 'copy', 'slim', 'sass']
