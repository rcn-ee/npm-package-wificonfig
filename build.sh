#!/bin/bash -e

DIR=$PWD

export NODE_PATH=/usr/local/lib/node_modules

npm_options="--unsafe-perm=true --progress=false --loglevel=error --prefix /usr/local"

echo "Resetting: /usr/local/lib/node_modules/"
rm -rf /usr/local/lib/node_modules/* || true

npm_git_install () {
	if [ -d /usr/local/lib/node_modules/${npm_project}/ ] ; then
		rm -rf /usr/local/lib/node_modules/${npm_project}/ || true
	fi

	if [ -d /tmp/${git_project}/ ] ; then
		rm -rf /tmp/${git_project}/ || true
	fi

	if [ ! "x${git_branch}" = "x" ] ; then
		git clone -b ${git_branch} ${git_user}/${git_project} /tmp/${git_project} --depth=1
	else
		git clone ${git_user}/${git_project} /tmp/${git_project}
	fi

	if [ -d /tmp/${git_project}/ ] ; then
		cd /tmp/${git_project}/

		if [ ! "x${git_sha}" = "x" ] ; then
			git checkout ${git_sha} -b tmp
		fi

		if [ ! "x${git_sub_project}" = "x" ] ; then
			cd /tmp/${git_project}/${git_sub_project}/
		fi

		package_version=$(cat package.json | grep version | awk -F '"' '{print $4}' || true)
		git_version=$(git rev-parse --short HEAD)
		echo "Building: ${npm_project}"

		case "${node_version}" in
		v0.12.*)
			echo "Patching ${git_project} for ${node_version}"
			exit 2
			;;
		v4.*)
			echo "Patching ${git_project} for ${node_version}"
			exit 2
			;;
		v6.*)
			echo "Patching ${git_project} for ${node_version}"
			exit 2
			;;
		esac

		TERM=dumb ${node_bin} ${npm_bin} install -g ${npm_options}

		cd ${DIR}/
		rm -rf /tmp/${git_project}/
	fi

	echo "Packaging: ${npm_project}"
	wfile="${npm_project}-${package_version}-${git_version}-${node_version}"
	cd /usr/local/lib/node_modules/
	if [ -f ${wfile}.tar.xz ] ; then
		rm -rf ${wfile}.tar.xz || true
	fi
	tar -cJf ${wfile}.tar.xz ${npm_project}/
	cd ${DIR}/

	if [ ! -f ./deploy/${wfile}.tar.xz ] ; then
		cp -v /usr/local/lib/node_modules/${wfile}.tar.xz ./deploy/
		echo "New Build: ${wfile}.tar.xz"
	fi
}

npm_install () {
	node_bin="/usr/bin/nodejs"
	npm_bin="/usr/bin/npm"

	unset node_version
	node_version=$(/usr/bin/nodejs --version || true)

	echo "npm: [`${node_bin} ${npm_bin} --version`]"
	echo "node: [`${node_bin} --version`]"

	npm_project="wificonfig"
	git_project="wifidog-server"
	git_sub_project=""
	git_branch="BBGW"
	git_user="https://github.com/Pillar1989"
	npm_git_install
}

npm_install
