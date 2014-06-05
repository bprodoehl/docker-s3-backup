/* jshint node: true */

module.exports = function (grunt) {

    var sqlUser = '\'' + process.env.DB_USER + '\'@\'%\'';
    var sqlCreateUser =  'CREATE USER ' + sqlUser + ' IDENTIFIED BY \'' + process.env.DB_PASSWORD +
                         '\';';
    var sqlCreateDB = 'CREATE DATABASE IF NOT EXISTS ' +
                       process.env.DB_NAME + ';';
    var sqlGrantUser = 'GRANT ALL ON ' + process.env.DB_NAME + '.* TO ' +
                       sqlUser + ';';

    grunt.initConfig({

        clean: {
            tmp: ['tmp']
        },

        aws_s3: {
          options: {
            // Use the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY variables
            uploadConcurrency: 5, // 5 simultaneous uploads
            downloadConcurrency: 5 // 5 simultaneous downloads
          },
          download_backup: {
            options: {
              bucket: process.env.AWS_S3_BUCKET
            },
            files: [
              {dest: '/', cwd: 'tmp/', exclude: 'logs/*', action: 'download'},
            ]
          },
        },

        exec: {
          unzip_wordpress: 'cd tmp && tar -xjpf latest.tar.bz2',
          unzip_db: 'cd tmp && bunzip2 latest.sql.bz2',
          mysql_create_user: 'mysql --user=' + process.env.DB_ADMIN_USER +
                                  ' --password=' + process.env.DB_ADMIN_PASSWORD +
                                  ' --host=' + process.env.DB_PORT_3306_TCP_ADDR +
                                  ' --port=' + process.env.DB_PORT_3306_TCP_PORT +
                                  ' -e "' + sqlCreateUser + '"',
          mysql_create_db: 'mysql --user=' + process.env.DB_ADMIN_USER +
                                  ' --password=' + process.env.DB_ADMIN_PASSWORD +
                                  ' --host=' + process.env.DB_PORT_3306_TCP_ADDR +
                                  ' --port=' + process.env.DB_PORT_3306_TCP_PORT +
                                  ' -e "' + sqlCreateDB + '"',
          mysql_grant_user: 'mysql --user=' + process.env.DB_ADMIN_USER +
                                  ' --password=' + process.env.DB_ADMIN_PASSWORD +
                                  ' --host=' + process.env.DB_PORT_3306_TCP_ADDR +
                                  ' --port=' + process.env.DB_PORT_3306_TCP_PORT +
                                  ' -e "' + sqlGrantUser + '"',
          mysql_restore: 'mysql --user=' + process.env.DB_USER +
                              ' --password=' + process.env.DB_PASSWORD +
                              ' --host=' + process.env.DB_PORT_3306_TCP_ADDR +
                              ' --port=' + process.env.DB_PORT_3306_TCP_PORT +
                              ' ' + process.env.DB_NAME + ' < tmp/latest.sql',
          replace_domain: 'php /tmp/Search-Replace-DB/srdb.cli.php' +
                               ' --user=' + process.env.DB_USER +
                               ' --pass=' + process.env.DB_PASSWORD +
                               ' --host=' + process.env.DB_PORT_3306_TCP_ADDR +
                               ' --name=' + process.env.DB_NAME +
                               ' --search=' + process.env.WP_ORIG_DOMAIN +
                               ' --replace=' + process.env.WP_NEW_DOMAIN
        },

        copy: {
            wordpress: {
                expand: true,
                dot  : true,
                cwd: 'tmp/' + process.env.WP_FOLDER_NAME,
                src: ['**'],
                dest: '/app'
            },
        }
    });

    grunt.registerTask('default', ['clean',
                                   'aws_s3',
                                   'exec:unzip_wordpress',
                                   'copy:wordpress',
                                   'exec:unzip_db',
                                   'exec:mysql_create_user',
                                   'exec:mysql_create_db',
                                   'exec:mysql_grant_user',
                                   'exec:mysql_restore',
                                   'exec:replace_domain']);

    grunt.loadNpmTasks('grunt-aws-s3');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-exec');
};
