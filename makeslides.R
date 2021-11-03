# File to compile all the Rmd files and output markdown documents and slides

# List of files
files = c("02_demand_estimation", "07_dynamics_singleagent", "08_dynamics_games")

# Ask whether to compile code
args = commandArgs(trailingOnly=TRUE)
print(args)
if (length(args)==1) {
  
  # Add files
  if (args[1]=="y") {
    code_files = c("12_blp_1995", "17_rust_1987")
    files = append(files, code_files)
  }
  
  # Load Julia
  if (!("JuliaCall" %in% (.packages()))) {
    library(JuliaCall)
    julia <- julia_setup("/Users/mcourt/Documents/Julia-1.5.app/Contents/Resources/julia/bin")
  }
}

# Loop over files
for (file in files) {
  
  # Make HTML Slides
  rmarkdown::render(input = paste0('Rmd/', file, '.Rmd'), 
                    output_dir = 'output/', 
                    output_format = c('ioslides_presentation', 'md_document'), 
                    envir = new.env())
}
