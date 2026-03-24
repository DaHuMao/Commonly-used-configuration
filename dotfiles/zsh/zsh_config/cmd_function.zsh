function open_au() {
  open -a "Adobe Audition 2024" $1
}

functio new_branch(){
  branch_name=$1
  git checkout -b $branch_name
  git push --set-upstream origin $branch_name
}
