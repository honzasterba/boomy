CREATE TABLE `booms` (
  `id` int(11) NOT NULL auto_increment,
  `link` text NOT NULL,
  `title` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `kind` varchar(255) NOT NULL,
  `popularity` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `index_booms_on_user_id` (`user_id`),
  KEY `index_booms_on_created_at` (`created_at`),
  KEY `index_booms_on_popularity` (`popularity`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `points` (
  `id` int(11) NOT NULL auto_increment,
  `boom_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_points_on_boom_id_and_user_id` (`boom_id`,`user_id`),
  KEY `index_points_on_user_id` (`user_id`),
  KEY `index_points_on_boom_id` (`boom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `boom_id` int(11) default NULL,
  `tag_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_taggings_on_boom_id_and_tag_id` (`boom_id`,`tag_id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_boom_id` (`boom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_czech_ci default NULL,
  `slug` varchar(255) collate utf8_czech_ci default NULL,
  `popularity` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_tags_on_popularity` (`popularity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `nick` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `admin` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (7)