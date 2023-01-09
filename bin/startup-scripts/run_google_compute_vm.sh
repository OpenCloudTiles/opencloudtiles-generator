#!/bin/bash

set -ex

script_src="https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin"
env_file="/etc/profile"

function get_env() {
	key=$1
	value=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/$key" -H "Metadata-Flavor: Google")
	cmd="export $key=\"$value\""
	eval "$cmd"
	echo "$cmd" | sudo tee -a $env_file
}

get_env "TILE_SRC"
get_env "TILE_BBOX"
get_env "TILE_NAME"
get_env "TILE_DST"

source $env_file

curl -Ls "$script_src/processing-scripts/1_setup.sh" | sudo bash
curl -Ls "$script_src/processing-scripts/2_prepare_tilemaker.sh" | bash
curl -Ls "$script_src/processing-scripts/3_convert.sh" | bash

cd ~/tilemaker/build/shortbread-tilemaker

gsutil cp "$TILE_NAME.mbtiles" "$TILE_DST"

sudo shutdown -P now