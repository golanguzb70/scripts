#!/bin/bash

install_jq() {
    if command -v jq &>/dev/null; then
        echo "jq is already installed."
    else
        echo "Installing jq..."
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS
            brew install jq
        elif [[ "$(uname)" == "Linux" ]]; then
            # Linux (Debian/Ubuntu)
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo "Error: Unsupported operating system. Please install jq manually."
            exit 1
        fi
    fi
}
install_jq

# GitLab API endpoint
GITHUB_API="https://api.github.com/user/repos"
GITHUB_USERNAME=$GITHUB_USERNAME

if [$GITHUB_USERNAME = '']; then 
    echo "Enter your github username >>>"  
    read GITHUB_USERNAME
fi

if [$GITHUB_PERSONAL_ACCESS_TOKEN = '']; then
    echo "Enter your github  access token >>>"
    read GITHUB_PERSONAL_ACCESS_TOKEN
fi

if [ -d ".git" ]; then
    echo "You already have a git control in this repository."
    options="Continue Cancel"
    select opt in $options 
    do 
        if [ "$opt" == "Cancel" ]; then
           exit
        else 
            rm -r .git
            break
        fi
    done
fi


# Name of the new repository to create
echo "Enter a repository name"
read REPO_NAME

# Description for the new repository (Optional)
echo "Enter description of your repository."
read REPO_DESCRIPTION

# Visibility level of the new repository: public, internal, or private (Optional)
VISIBILITIES="private public"
VISIBILITY=""
select vis in $VISIBILITIES 
do 
    if [ "$vis" == "private" ]; then
        VISIBILITY="private"
    else 
        VISIBILITY="public"
    fi
    break
done

create_repository() {
    local response
    response=$(curl --header "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" --request POST \
        --data "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESCRIPTION\"}" \
        "$GITHUB_API")

    if [ $? -eq 0 ]; then
        if [ "$(echo "$response" | jq '.message')" = "null" ]; then
            echo "Repository created successfully."
        else
            echo "Error: $(echo "$response" | jq -r '.message')"
            exit 1
        fi
    else
        echo "Error: Failed to communicate with GitHub API."
        exit 1
    fi
}

connect_to_remote_repository() {
    git init
    git add -A
    git commit -m "initial commit"
    # Open main branch
    git branch -M main
    # Add the remote repository URL
    git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
    # Push the local repository to the remote repository
    git push -u origin main

    echo "Connected the current folder to the remote repository successfully."
}

# Call the functions to create a new repository (if needed) and connect to the remote repository
create_repository
connect_to_remote_repository