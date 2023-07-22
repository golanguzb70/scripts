#!/bin/bash

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

# Function to install jq if not already installed
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

# Function to create a new repository on GitLab using GitLab API
create_gitlab_repository() {
    # GitLab API endpoint
    GITLAB_API="https://gitlab.com/api/v4/projects"

    # Prompt for GitLab username and personal access token if not provided
    if [ "$GITLAB_USERNAME" = "" ]; then
        echo -n "Enter your GitLab username: "
        read -r GITLAB_USERNAME
    fi

    if [ "$GITLAB_PERSONAL_ACCESS_TOKEN" = "" ]; then
        echo -n "Enter your GitLab personal access token: "
        read -r GITLAB_PERSONAL_ACCESS_TOKEN
    fi

    # GitLab repository name
    echo -n "Enter the GitLab repository name: "
    read -r REPO_NAME

    # GitLab repository description (Optional)
    echo -n "Enter the GitLab repository description (leave blank for no description): "
    read -r REPO_DESCRIPTION

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

    # Create the GitLab repository using GitLab API
    local response
    response=$(curl --header "PRIVATE-TOKEN: $GITLAB_PERSONAL_ACCESS_TOKEN" --request POST \
        --data "name=$REPO_NAME&description=$REPO_DESCRIPTION&visibility=$VISIBILITY" \
        "$GITLAB_API")

    if [ $? -eq 0 ]; then
        if [ "$(echo "$response" | jq '.message')" = "null" ]; then
            echo "Repository created successfully on GitLab."
        else
            echo "Error: $(echo "$response" | jq -r '.message')"
            exit 1
        fi
    else
        echo "Error: Failed to communicate with GitLab API."
        exit 1
    fi
}

# Function to connect the current folder to the remote GitLab repository
connect_to_gitlab_repository() {
    git init --initial-branch=main
    git remote add origin git@gitlab.com:$GITLAB_USERNAME/$REPO_NAME.git
    git add .
    git commit -m "Initial commit"
    git push --set-upstream origin main

    echo "Connected the current folder to the remote GitLab repository successfully."
}

# Call the function to install jq if needed
install_jq

create_gitlab_repository
connect_to_gitlab_repository