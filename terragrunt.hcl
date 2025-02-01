terraform {
  source = "./devops"
}

inputs = {
  root_path = get_working_dir()
}
