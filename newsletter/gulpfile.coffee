do ->

	# Load all plugins
	gulp = require "gulp"
	del = require "del"
	path = require "path"
	browserSync = require "browser-sync"
	changed = require "gulp-changed"
	jade = require "gulp-jade"
	data = require "gulp-data"
	stylus = require "gulp-stylus"
	inlineCss = require "gulp-inline-css"
	image = require "gulp-image"
	plumber = require "gulp-plumber"
	notify = require "gulp-notify"

	# Inserting paths variable
	sourceRoot = "./source/"
	hmlRoot = "./hml/"
	prodRoot = "./prod/"

	paths =
		source:
			jade: "#{sourceRoot}/jade/"
			stylus: "#{sourceRoot}/stylus/"
			content: "#{sourceRoot}/content/"
		hml:
			css: "#{hmlRoot}/css/"
			img: "#{hmlRoot}/img/"
		prod:
			css: "#{prodRoot}/css/"
			img: "#{prodRoot}/img/"

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

		gulp.watch(
			"#{paths.source.jade}**/*.jade"
			["inline-css"]
		).on "change", browserSync.reload

		gulp.watch(
			"#{paths.source.stylus}**/*.styl"
			["inline-css"]
		).on "change", browserSync.reload
		return

	# Build template engine task
	gulp.task "jade", ->
		gulp.src "#{paths.source.jade}**/*.jade"
		.pipe plumber
			errorHandler: notify.onError "Erro ao compilar o Jade: <%= error.message %>"
		.pipe data ( file ) ->
			return require "#{paths.source.content}/#{path.basename( file.path, '.jade' )}.json"
		.pipe jade
			pretty:yes
		.pipe gulp.dest hmlRoot
		.pipe browserSync.stream()
		return

	# Build sass compile task
	gulp.task "stylus", ->
		gulp.src "#{paths.source.stylus}**/*.styl"
		.pipe plumber
			errorHandler: notify.onError "Erro ao compilar o Stylus: <%= error.message %>"
		.pipe stylus
			linenos: yes
		.pipe changed paths.hml.css,
			extension: ".css"
			hasChanged: changed.compareSha1Digest
		.pipe gulp.dest paths.hml.css
		.pipe browserSync.stream()
		return

	# Build task to insert inline css
	gulp.task "inline-css", ["stylus","jade"], ->
		setTimeout ->
			gulp.src "#{hmlRoot}**/*.html"
			.pipe plumber
				errorHandler: notify.onError "Erro ao deixar o CSS inline: <%= error.message %>"
			.pipe inlineCss
				applyStyleTags: no
				applyLinkTags: yes
				removeStyleTags: no
				removeLinkTags: yes
			.pipe changed hmlRoot,
				hasChanged: changed.compareSha1Digest
			.pipe gulp.dest hmlRoot
			.pipe browserSync.stream()
			return
		,1000
		return

	# Production code environment
	# Clean directories for publication
	gulp.task "clean", ->
		del ["#{hmlRoot}**/*.html","#{hmlRoot}css","#{prodRoot}*"], (err, paths) ->
			if err
				console.log "Ouve um erro ao limpar as pastas: #{err}"
				return
			else
    			console.log "Arquivos/pastas deletadas:\n", paths.join "\n"
    			return
    	return

	# Build HTML minify task
	gulp.task "optmize-html", ["clean"], ->
		gulp.src "#{paths.source.jade}**/*.jade"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar o HTML: <%= error.message %>"
		.pipe data ( file ) ->
			return "#{paths.source.jsonContent}/#{path.basename( file.path )}.json"
		.pipe jade()
		.pipe gulp.dest prodRoot
		return

<<<<<<< HEAD
	# Production code environment
	# Clean directories for publication
	gulp.task "clean-dir", ->
		del ["#{paths.hml.html}/*", "#{paths.hml.css}/*", "#{paths.prod.root}/*"], (err, paths) ->
			if err
				notify.onError "Erro ao deletar os arquivos: <%= error.message %>"
			else
    			console.log "Arquivos/pastas deletadas:\n", paths.join "\n"
		

	# # Build HTML minify task
	# Build template engine task
	gulp.task "optimize-html", ->
		gulp.src "#{paths.source.jade}**/*.jade"
		.pipe data ( file ) ->
			return "#{paths.source.jsonContent}/#{path.basename( file.path )}.json"
		.pipe jade()
		.pipe plumber
			errorHandler: notify.onError "Erro ao compilar o Jade: <%= error.message %>"
		.pipe gulp.dest prodRoot
		.pipe browserSync.stream()
		return

	# Build css optmizer task
	gulp.task "optmize-css", ["optmize-html"], ->
		gulp.src "#{paths.source.sass}**/*.scss"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar o CSS: <%= error.message %>"
		.pipe sass().on "error", sass.logError
		.pipe uncss
			html: ["#{paths.prod.html}**/*.html"]
		.pipe minifyCss
			compatibility: "ie8"
		.pipe gulp.dest paths.prod.css

	# # Build task to insert inline css
	# gulp.task "prod-insert-inline-css", ["optmize-css"], ->
	# 	gulp.src "#{paths.prod.html}**/*.hml"
	# 	.pipe plumber
	# 		errorHandler: notify.onError "Erro ao deixar o CSS inline para produção: <%= error.message %>"
	# 	.pipe inlineCss
	# 		applyStyleTags: no
	# 		applyLinkTags: yes
	# 		removeStyleTags: no
	# 		removeLinkTags: yes
	# 	.pipe gulp.dest paths.prod.html

	# # Build image optmizer task
	# gulp.task "optmize-images", ["clean-hml-and-prod"], ->
	# 	gulp.src "./#{paths.source.img}{**/*.{jpg,png,gif},*.{jpg,png,gif}}"
	# 	.pipe plumber
	# 		errorHandler: notify.onError "Erro ao otimizar as imagens: <%= error.message %>"
	# 	.pipe imagemin
	# 		progressive: yes
	# 		interlaced: yes
	# 		optimizationLevel: 7
	# 		svgoPlugins: [
	# 			removeViewBox: no
	# 		]
	# 	.pipe gulp.dest "#{paths.prod.img}"
=======
	# Build css optmizer task
	gulp.task "optmize-css", ["clean"], ->
		gulp.src "#{paths.source.stylus}**/*.styl"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar o CSS: <%= error.message %>"
		.pipe stylus
			compress: yes
		.pipe gulp.dest paths.prod.css
		return

	# Build task to insert inline css
	gulp.task "optmize-inline-css", ["optmize-css","optmize-html"], ->
		setTimeout ->
			gulp.src "#{prodRoot}**/*.html"
			.pipe plumber
				errorHandler: notify.onError "Erro ao deixar o CSS inline: <%= error.message %>"
			.pipe inlineCss
				applyStyleTags: no
				applyLinkTags: yes
				removeStyleTags: no
				removeLinkTags: yes
			.pipe gulp.dest prodRoot
			return
		,1000
		return

	# Build image optmizer task
	gulp.task "optmize-images", ["clean"], ->
		gulp.src "#{paths.hml.img}{**/*.{jpg,png,gif},*.{jpg,png,gif}}"
		.pipe plumber
			errorHandler: notify.onError "Erro ao otimizar as imagens: <%= error.message %>"
		.pipe image()
		.pipe gulp.dest "#{paths.prod.img}"
		return
>>>>>>> 12b3a80e2e3e5ed9a36a055a7d5d158af3ec1145

	# Set task for homologation
	gulp.task "default", ["browser-sync","inline-css"]

	# Set task for production
	gulp.task "prod", ["optmize-inline-css","optmize-images"]