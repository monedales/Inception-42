<?php
/**
 * This file is intentionally left as documentation only.
 *
 * In this project, wp-config.php is NOT shipped statically. It is generated
 * at container start by wp-cli (`wp config create`) inside tools/setup.sh,
 * so the database credentials come from the .env variables and the Docker
 * secrets at runtime — nothing sensitive is written into the image or the repo.
 *
 * A static version would hardcode values like:
 *
 *   define( 'DB_NAME',     'wordpress' );
 *   define( 'DB_USER',     'wp_user'   );
 *   define( 'DB_PASSWORD', '...'       );   // <- secret, must NOT be hardcoded
 *   define( 'DB_HOST',     'mariadb'   );   // service name on the docker network
 *
 * See tools/setup.sh for the actual generation step.
 */
