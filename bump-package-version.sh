LABEL="$1"

# @latest version on npm
latestVersionNPM=$(npm show . dist-tags.latest --json)
echo "Latest dist-tag version on npm: $latestVersionNPM"

# Initial package.json version
initialPackageJSON=$(sed -nE 's/^\s*"version": "([0-9]+.[0-9]+.[0-9]+).*?",$/\1/p' package.json)
echo "Initial package.json version: $initialPackageJSON"

# Set package.json to @latest version on npm
sed -i 's/\("version": \)\("[0-9]\+.[0-9]\+.[0-9]\+"\)/\1\'$latestVersionNPM'/' package.json
echo "Updated local package.json: $latestVersionNPM"

# Bump the package.json version, accordingly to the label.
case "$LABEL" in
	*"major"*)
		echo "Bumping pre-major version"
		echo "$(npm version --no-git-tag-version premajor --preid alpha)"
		;;
	*"minor"*)
		echo "Bumping pre-minor version"
		echo "$(npm version --no-git-tag-version preminor --preid alpha)"
		;;
	*"patch"*)
		echo "Bumping pre-patch version"
		echo "$(npm version --no-git-tag-version prepatch --preid alpha)"
		;;
	*)
		echo "No [major, minor, patch] label has been set"
		exit 1
		;;
esac

# Bumped package.json version
bumpedPackageJSONVersion=$(sed -nE 's/^\s*"version": "([0-9]+.[0-9]+.[0-9]+).*?",$/\1/p' package.json)

# Get all published versions on npm.
allVersionsArray=$(npm show . versions)

# Get the current version from the package.json
upToDatePackageJSON=$(sed -nE 's/^\s*"version": "([0-9]+.[0-9]+.[0-9]+).*?",$/\1/p' package.json)

# Identify the latest published alpha (if any) on npm, of the upToDatePackageJSON.
for i in ${allVersionsArray[@]}
do
	if [[ $i == *$upToDatePackageJSON* ]]; then
		latestAlphaVersion=$(echo $i)
	fi
done

# Get the alpha counter value of the latest alpha version (for the upToDatePackageJSON version).
alphaVersionCounter="$(echo "$latestAlphaVersion" | grep -oP '(?:-alpha.)\K\d+')"

# Bumping the alphaVersionCounter by 1.
if [[ "$alphaVersionCounter" != "" ]];
	then
		alphaVersionCounter="$((alphaVersionCounter+1))"
	else
		alphaVersionCounter="0"
fi

# Set alpha tag to the correspondent version
echo "Setting alpha version to $alphaVersionCounter"
sed -i 's/\("version": "[0-9]\+.[0-9]\+.[0-9]\+\)\(-alpha.\)\([0-9]\)/\1\'-alpha.$alphaVersionCounter'/' package.json

# If there was version bump, commit changes
if [[ "$initialPackageJSON" != "$upToDatePackageJSON" ]];
	then
		git add package.json
		git commit -m "autobump $upToDatePackageJSON"
fi
