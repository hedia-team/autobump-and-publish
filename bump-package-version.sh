# @latest on npm
latestVersionNPM=$(npm show ./ dist-tags.latest --json)
echo "Latest dist-tag version on npm: $latestVersionNPM"

# Initial package.json version
packageJSONVersion=$(sed -nE 's/^\s*"version": "([0-9]+.[0-9]+.[0-9]+).*?",$/\1/p' package.json)
echo "Initial package.json version: $packageJSONVersion"

npmV=`echo $latestVersionNPM | sed 's/\.//g' | bc`
pkgV=`echo $packageJSONVersion | sed 's/\.//g' | bc`

# Check if the packageJSONVersion is up to date.
# Otherwise, bump the package.json version, accordingly to the label.
if [[ $npmV -lt $pkgV ]]; then
    echo "package.json version is up to date"
else
	# Set package.json to latest NPM version prior to bump version
	sed -i 's/\("version": \)\("[0-9]\+.[0-9]\+.[0-9]\+\)\(\"\)/\1\'$latestVersionNPM'/' package.json
    case "$1" in
	*"major"*)
		echo "Bumping pre-major version"
		echo "$(npm version --no-git-tag-version premajor --preid alpha)"
		;;
	*"minor"*)
		echo "Bumping pre-minor version"
		echo $(npm version --no-git-tag-version preminor --preid alpha)
		;;
	*"patch"*)
		echo "Bumping pre-patch version"
		echo "$(npm version --no-git-tag-version prepatch --preid alpha)"
		;;
	*)
		echo "No [major, minor, patch] label has been set"
		;;
  esac
fi

# Get all published versions on npm.
allVersionsArray=$(npm show ./ versions)
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

# Get the current packageVersion and check if -alpha.X tag has been set (in case of package.json version bump (Open PR))
packageVersion=$(sed -nE 's/^\s*"version": "(.*?)",$/\1/p' package.json)
if [[ "$packageVersion" == *"-alpha"* ]];
then
	# On open PR
	# Set alpha tag to the correspondent version
	echo "Setting alpha version to $alphaVersionCounter"
	sed -i 's/\("version": "[0-9]\+.[0-9]\+.[0-9]\+\)\(-alpha.\)\([0-9]\)/\1\'-alpha.$alphaVersionCounter'/' package.json
	# Commit changes
	git add package.json
	git commit -m "autobump $upToDatePackageJSON"
else
	echo "on push"
	# On push commit
	# Set alpha tag to the correspondent version
	echo "Setting alpha version to $alphaVersionCounter"
	sed -i 's/\("version": "\)\([0-9]\+\.[0-9]\+\.[0-9]\+\)\("\)/\1\2\-alpha.'$alphaVersionCounter'\3/' package.json
fi
