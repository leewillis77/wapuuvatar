module.exports = function ( grunt ) {

	// Project configuration.
	grunt.initConfig( {
						  pkg: grunt.file.readJSON( 'package.json' ),
						  responsive_images: {
							  dev: {
								  files: [ {
									  expand: true,
									  src: [ '*.png' ],
									  cwd: 'src/',
									  dest: 'dist/'
								  } ],
								  options: {
									  engine: "im",
									  sizes: [
										  {
											  name: '64',
											  width: 64,
											  height: 64
										  },
										  {
											  name: "256",
											  width: 256,
											  height: 256
										  }
									  ],
								  }
							  }
						  },
						  image: {
							  dynamic: {
								  options: {
									  optipng: true,
								  },
								  files: [ {
									  expand: true,
									  cwd: 'dist/',
									  src: [ '**/*.png' ],
									  dest: 'dist/'
								  } ]
							  }
						  },
					  } );

	grunt.loadNpmTasks( 'grunt-responsive-images' );
	grunt.loadNpmTasks( 'grunt-image' );

	// Default task(s).
	grunt.registerTask( 'default', [ 'responsive_images', 'image']);
};
