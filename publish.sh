publish_html(){
    # Get the current directory
current_dir=$(pwd)

# Start searching from the current directory
search_dir="$current_dir"

# Flag to track whether the "output" folder is found
found_output_folder=false

# Loop until the root directory is reached
while [ "$search_dir" != "/" ]; do
  # Check if "output" folder exists in the current directory
  if [ -d "$search_dir/output" ]; then
    found_output_folder=true
    source_directory="$search_dir/analysis"
    target_folder=""

    if ls "$source_directory"/*.html &> /dev/null; then
      # Check if the "docs" folder exists
      if [ -d "$search_dir/docs" ]; then
        target_folder="$search_dir/docs"
      # Check if the "public" folder exists
      elif [ -d "$search_dir/public" ]; then
        target_folder="$search_dir/public"
      fi

      html_files=`find $source_directory -type f -name "*.html"`
      echo $html_files
      # Move all HTML files to the target folder
      mv "$source_directory"/*.html "$target_folder/"
      echo "HTML files moved to '$target_folder/'."

      # Search for folders with the same base name as HTML files
      for file in $html_files; do
        folder_name=$(basename "$file" .html)
        
        if [ -d "$source_directory/$folder_name" ]; then
          mv "$source_directory/$folder_name" "$search_dir/figures/"
          echo "Folder '$folder_name' moved to '$search_dir/figures/'."
        fi

      done
    else
      echo "No HTML files to move. Have you forgotten knitting your markdown?"
    fi

    break
  else
    # Move one level up
    search_dir=$(dirname "$search_dir")
  fi
done

if [ "$found_output_folder" = false ]; then
  echo "You are not in any workflow project! Please make sure you are in a project directory."
fi
}