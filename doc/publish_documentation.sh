#!/bin/sh

set -e;


if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo "INFO: This is a PR.";
    echo "INFO: Not building docs.";
    exit 0;
fi;


if [ "${TRAVIS_BRANCH}" != "master" ]; then
    echo "INFO: We are not on the master branch.";
    echo "INFO: Not building docs.";
    exit 0;
fi;


if [ -z "$GH_TOKEN" ]; then
    echo "INFO: The GitHub access token is not set.";
    echo "INFO: Not building docs.";
    exit 0;
fi;


if [ -z "$(git ls-remote --heads https://github.com/${TRAVIS_REPO_SLUG} gh-pages)" ]; then
    echo "INFO: The branch gh-pages does not exist.";
    echo "INFO: Not building docs.";
    exit 0;
fi;


function gh_pages_prepare()
{
    mkdir -p "${SOURCE_DIR}/build/doc";
    cd "${SOURCE_DIR}/build/doc";

    git init;
    git remote add origin https://github.com/${TRAVIS_REPO_SLUG};
    git fetch origin --depth 1;
    git checkout gh-pages;

    git config user.name "Travis CI";
    git config user.email "travis@travis-ci.org";

    rm -f .git/index;
    git clean -df;
}


function gh_pages_generate()
{
    cd "${SOURCE_DIR}/build";

    cmake ..;

    make doc;
}


function gh_pages_update()
{
    cd "${SOURCE_DIR}/build/doc/";

    touch .nojekyll;

    git add --all ".nojekyll" "doxygen/html" "sphinx/html";

    git commit --quiet -m "Documentation build from Travis for commit ${TRAVIS_COMMIT}";

    git remote add upstream https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG};
    git push --quiet --force upstream gh-pages > /dev/null 2>&1;
}


cd "${SOURCE_DIR}";
gh_pages_prepare;
gh_pages_generate;
gh_pages_update;
