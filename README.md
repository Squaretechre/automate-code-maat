# To run Analyze.sh

The script was written to run on Windows so you'll need to tweak a few things for OSX, to run:

1. Grab Code Maat from [here](http://www.adamtornhill.com/code/crimescenetools) and move the .jar and .bat file to C:\codemaat   - the script expect it to live at C:\codemaat, change path in script as needed
2. Add analyze.sh to your path
3. Add maat.bat from C:\codemaat to your path
4. Create a folder in C:\codemaat\analysis and copy the d3 folder and index.html into it
5. Install Cloc globally, 'npm i cloc -g' - https://www.npmjs.com/package/cloc
6. Install Python 2.7 and make sure Python is on your path, confirm with 'python --version'
7. cd into the repo to run the analysis on
8. Run analyze.sh using the parameters below
9. cd to where your analysis was copied to, C:\codemaat\analysis\ by default
10. D3 will try to load a file called analysis_visualisation.json by default which is set in index.html, if you change the file prefix with the -p parameter, make sure to update this the filename in index.html
11. Run a local server in that folder using Python for instance, > python -m SimpleHTTPServer 8000
12. Hit localhost:8000 to see the D3 hot spot visualisation

## Parameters

-p | --prefix
Prefix to add to output files i.e. 'myorganisation_frequency.csv' - defaults to 'analysis'

-v | --vispath
Path to save the visualisation JSON file to

-s | --searchpath
Path to run the complexity analysis on using Cloc

-l | --includeLang
Languages to include in analysis in csv format

-d | --excludeDir
Directories to exclude from analysis in csv format

-f | --excludeExt
File extensions to exclude in csv format


Example:
analyze.sh -p analysis -v /c/codemaat/analysis/ -s ./ -l cs,js -d node_modules -f csproj,css


You can read more about Cloc's parameters at:
https://www.npmjs.com/package/cloc

More about Code Maat here:
https://github.com/adamtornhill/code-maat