dev:
	@trap 'kill 0' INT TERM EXIT; \
	(cd layout_engine && fvm flutter run -d macos) & \
	(cd game_server && dart run) & \
	(cd client && fvm flutter run -d chrome) & \
	wait
