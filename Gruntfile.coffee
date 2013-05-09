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

    concat:
      all:
        options:
          banner: '<%= meta.banner %>'
        files:
          'dist/spine.paginator.js': 'dist/spine.paginator.js'

    uglify:
      all:
        options:
          banner: '<%= meta.banner %>'
          report: 'gzip'
        files:
          'dist/spine.paginator.min.js': 'dist/spine.paginator.js'

    jasmine:
      all:
        src: 'dist/spine.paginator.js'
        options:
          specs: 'spec/spine.paginator/**/*.js'
          helpers: 'spec/lib/**/*.js'

    watch:
      all:
        files: 'src/spine.paginator.coffee'
        tasks: ['build', 'spec']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'spec',    ['jasmine']
  grunt.registerTask 'build',   ['coffee', 'concat', 'uglify']
