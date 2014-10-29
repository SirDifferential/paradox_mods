#!/bin/bash
# Copies existing vanilla EU4 files to a temporary work dir and patches them
# Make sure to check the paths below if you use this script

VANILLA_DIR="/d/steamgames/SteamApps/common/Europa Universalis IV"
MOD_DIR="/c/Users/gekko/Documents/Paradox Interactive/Europa Universalis IV/mod/gtech2"

if [ ! -d "$VANILLA_DIR" ]; then
    echo "cannot patch: your vanilla game is not installed to the correct directory"
    exit 1
fi

if [ ! -d "$MOD_DIR" ]; then
    echo "Mod dir did not exist. Creating it at $MOD_DIR"
    mkdir "$MOD_DIR"
    if [ $? -ne 0 ]; then
        echo "Could not create the mod dir. Most likely a permission error."
        exit 1
    fi
fi

if [ ! -d "$MOD_DIR/work" ]; then
    mkdir "$MOD_DIR/work"
fi

if [ ! -d "$MOD_DIR/work/history" ]; then
    mkdir "$MOD_DIR/work/history"
fi

if [ ! -d "$MOD_DIR/work/history/countries" ]; then
    mkdir "$MOD_DIR/work/history/countries"
fi

echo "Copying country files"

cp -v "$VANILLA_DIR/history/countries/"* "$MOD_DIR/work/history/countries/"
cd "$MOD_DIR/work/history/countries"

echo "Patching native governments to feudal monarchy to prevent native american tech cheat"
sed -i 's/.*native_council.*/government = feudal_monarchy/g' *

echo "Patching all tech groups to western"
sed -i 's/.*technology_group.*/technology_group = western/g' *

echo "Patching Ming to get westernized decisions"

if [ ! -d "$MOD_DIR/work/events" ]; then
    mkdir "$MOD_DIR/work/events"
fi

echo "Copying Ming events"
cp -v "$VANILLA_DIR/events/flavorMNG.txt" "$MOD_DIR/work/events"
cd "$MOD_DIR/work/events"
sed -n -i '/No more Celestial Empire/q;p' flavorMNG.txt
echo '
# No more Celestial Empire
country_event = {
	id = flavor_mng.17
	title = flavor_mng.17.t
	desc = flavor_mng.17.d
	picture = COURT_eventPicture
	
	fire_only_once = yes
	
	trigger = {
		technology_group = western
		tag = MNG
	}
	
	option = {
		name = flavor_mng.17.a
		remove_country_modifier = mng_closed_china
		remove_country_modifier = mng_open_china
		if = {
			limit = {
				government = celestial_empire
			}
			change_government = feudal_monarchy
		}
	}
}
' >> flavorMNG.txt

echo "Patching assorted nations so they only get western units and tech from decisions"
if [ ! -d "$MOD_DIR/work/decisions" ]; then
    mkdir "$MOD_DIR/work/decisions"
fi

cp -v "$VANILLA_DIR/decisions/BukharaNation.txt" "$MOD_DIR/work/decisions/"
cp -v "$VANILLA_DIR/decisions/ManchuDecisions.txt" "$MOD_DIR/work/decisions/"
cp -v "$VANILLA_DIR/decisions/PersianNation.txt" "$MOD_DIR/work/decisions/"
cp -v "$VANILLA_DIR/decisions/MughalNation.txt" "$MOD_DIR/work/decisions/"
cp -v "$VANILLA_DIR/decisions/Tribal.txt" "$MOD_DIR/work/decisions/"

cd "$MOD_DIR/work/decisions"
sed -i 's/.*change_technology_group.*/change_technology_group = western/g' *
sed -i 's/.*change_unit_type.*/change_unit_type = western/g' *
echo "All done!"
