do ->

	# Load all plugins
	gulp = require "gulp"
	del = require "del"
	path = require "path"
	browserSync = require "browser-sync"
	jade = require "gulp-jade"
	data = require "gulp-data"
	stylus = require "gulp-stylus"
	nib = require "nib"
	image = require "gulp-image"
	babel = require "gulp-babel"
	es2015 = require "babel-preset-es2015"
	plumber = require "gulp-plumber"
	notify = require "gulp-notify"
	changed = require "gulp-changed"
	include = require "gulp-include"

	# Inserting paths variable
	sourceRoot = "./source/"
	hmlRoot = "./hml/"
	prodRoot = "./prod/"

	paths =
		source:
			jade: "#{sourceRoot}/jade/"
			stylus: "#{sourceRoot}/assets/stylus/"
			js: "#{sourceRoot}/assets/js/"
			content: "#{sourceRoot}/content/"
			includes: "#{sourceRoot}/includes/"
		hml:
			img: "#{hmlRoot}/assets/img/"
			css: "#{hmlRoot}/assets/css/"
			js: "#{hmlRoot}/assets/js/"
			font: "#{hmlRoot}/assets/font/"
		prod:
			img: "#{prodRoot}/assets/img/"
			css: "#{prodRoot}/assets/css/"
			js: "#{prodRoot}/assets/js/"
			font: "#{prodRoot}/assets/font/"

	# Source code environment
	# Build browser sync task
	gulp.task "browser-sync", ->
		browserSync
			browser: "google chrome"
			logLevel: "debug"
			logPrefix: "Homologation"
			notify: yes
			open: "external"
			port: 3000
			server:
				baseDir: hmlRoot
				index: "index.html"

		gulp.watch [
			"#{paths.source.jade}**/*.jade",
			"#{paths.source.includes}**/*.jade",
			"#{paths.source.content}**/*.json"
		], ["jade"]
		.on "change", browserSync.reload

		gulp.watch "#{paths.source.stylus}**/*.styl", ["stylus"]
		.on "change", browserSync.reload

		gulp.watch "#{paths.source.js}**/*.js", ["js"]
		.on "change", browserSync.reload

	# Build template engine task
	gulp.task "jade", ->
		gulp.src "#{paths.source.jade}**/*.jade"
		.pipe plumber
			errorHandler: notify.onError "Erro ao compilar o jade: <%= error.message %>"
		.pipe data ( file ) ->
			return require "#{paths.source.content}/#{path.basename( file.path, '.jade' )}.json"
		.pipe jade
			pretty: yes
			cache: no
		.pipe changed hmlRoot,
			extension: ".html"
			hasChanged: changed.compareSha1Digest
		.pipe gulp.dest hmlRoot
		.pipe browserSync.stream()

	# Build sass compile task
	gulp.task "stylus", ->
		gulp.src "#{paths.source.stylus}**/*.styl"
		.pipe plumber
			errorHandler: notify.onError "Erro ao compilar o Stylus: <%= error.message %>"
		.pipe stylus
			use: nib()
			linenos: yes
		.pipe changed paths.hml.css,
			extension: ".css"
			hasChanged: changed.compareSha1Digest
		.pipe gulp.dest paths.hml.css
		.pipe browserSync.stream()

	# Build coffee compile task
	gulp.task "js", ->
		gulp.src "#{paths.source.js}**/*.js"
		.pipe plumber
			errorHandler: notify.onError "Erro ao compilar o Javascript: <%= error.message %>"
		.pipe babel
			presets: ["es2015"]
		.pipe include()
		.pipe changed paths.hml.js,
			hasChanged: changed.compareSha1Digest
		.pipe gulp.dest paths.hml.js
		.pipe browserSync.stream()

	# Production code environment
	# Clean directories for publication
	gulp.task "clean", ->
		del ["#{prodRoot}*","#{hmlRoot}**/*.html","#{hmlRoot}assets/css","#{hmlRoot}assets/js"], (err, paths) ->
			console.log err
			if err
				console.log "Ocorreu um erro ao deletar os arquivos: ", err
			else
    			console.log "Arquivos/pastas deletadas:\n", paths.join "\n"

	# Build HTML minify task
	gulp.task "optmize-html", ["clean"], ->
		gulp.src "#{paths.source.jade}**/*.jade"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar o HTML: <%= error.message %>"
		.pipe data ( file ) ->
			return require "#{paths.source.content}/#{path.basename( file.path, '.jade' )}.json"
		.pipe jade()
		.pipe gulp.dest prodRoot

	# Build css optmizer task
	gulp.task "optmize-css", ["clean"], ->
		gulp.src "#{paths.source.stylus}**/*.styl"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar o CSS: <%= error.message %>"
		.pipe stylus
			compress: yes
			use: nib()
		.pipe gulp.dest paths.prod.css

	# Build js optmizer task
	gulp.task "optmize-js", ["clean"], ->
		gulp.src "#{paths.source.js}**/*.js"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar o JS: <%= error.message %>"
		.pipe babel
			presets: ["es2015"]
			compact:  yes
			comments: no
		.pipe include()
		.pipe gulp.dest paths.prod.js

	# Build image optmizer task
	gulp.task "optmize-images", ["clean"], ->
		gulp.src "#{paths.hml.img}{**/*.{jpg,png,gif,svg},*.{jpg,png,gif,svg}}"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar as imagens: <%= error.message %>"
		.pipe image()
		.pipe gulp.dest "#{paths.prod.img}"

	# Build font optmizer task
	gulp.task "optmize-fonts", ["clean"], ->
		gulp.src "#{paths.hml.font}{**/*.{eot,svg,ttf,woff,woff2},*.{eot,svg,ttf,woff,woff2}}"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar as fontes: <%= error.message %>"
		.pipe gulp.dest "#{paths.prod.font}"

	# Set task for homologation
	gulp.task "default", ["browser-sync","jade","stylus","js"]

	# Set task for production
	gulp.task "prod", ["optmize-html","optmize-css","optmize-js","optmize-images","optmize-fonts"]