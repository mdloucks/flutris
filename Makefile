dev:
	@trap 'kill 0' INT TERM EXIT; \
	(cd layout_engine && fvm flutter run -d macos) & \
	(cd game_server && dart run) & \
	(cd client && fvm flutter run -d chrome --wasm) & \
	wait

# Only run game server & layout engine so we can get hot reload for web
dev-web:
	@trap 'kill 0' INT TERM EXIT; \
	(cd layout_engine && fvm flutter run -d macos) & \
	(cd game_server && dart run) & \
	wait

dev-server:
	@trap 'kill 0' INT TERM EXIT; \
	(cd layout_engine && fvm flutter run -d macos) & \
	(cd client && fvm flutter run -d chrome --wasm) & \
	wait
