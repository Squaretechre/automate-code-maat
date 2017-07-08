prefix=analysis
visualisationPath='./'
searchPath='./'
includedLanguages=''
excludedDirectories=''
excludedFileExtensions=''

while [ "$1" != "" ]; do
    case $1 in
        -p | --filePrefix )     shift
                                prefix=$1
                                ;;
        -v | --visPath )        shift
                                visualisationPath=$1
                                ;;
        -s | --searchPath )     shift
                                searchPath=$1
                                ;;
        -l | --includeLang )   shift
                                includedLanguages=$1
                                ;;
        -d | --excludeDir )    shift
                                excludedDirectories=$1
                                ;;
        -f | --excludeExt )    shift
                                excludedFileExtensions=$1
                                ;;
    esac
    shift
done

prefix=$prefix'_'
visualisationFile=$prefix'visualisation.json'
evolutionFile=$prefix'evolution.log'
slocFile=$prefix'lines.csv'
changeFrequencyFile=$prefix'frequency.csv'

spinner()
{
    disable_cursor
    local pid=$1
    local delay=0.25
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "[%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    sleep 0.5
    printf "   \b\b\b"
    enable_cursor
}

disable_cursor() {
    printf "\e[?25l"
}

enable_cursor() {
    printf "\e[?25h"
}

print_progress_message() {
    message=$1
    echo ''
    echo $message
    echo '--------------------'
}

clean_old_files() {
    print_progress_message 'bash: cleaning old files'
    rm -rf $evolutionFile $changeFrequencyFile $slocFile $visualisationFile
}

create_version_control_log() {
    print_progress_message 'git: creating version control log'
    git log --pretty=format:'[%h] %an %ad %s' --date=short --numstat > $evolutionFile
}

generate_code_maat_summary() {
    print_progress_message 'code maat: generating code maat summary from version control log'
    maat.bat -l $evolutionFile -c git -a summary >nul
}

generate_line_count_report() {
    print_progress_message 'cloc: generating line count report - lines of code in each file (sloc) used as proxy for complexity'
    echo $includedLanguages
    echo $excludedDirectories
    echo $excludedFileExtensions
    echo $searchPath
    echo $slocFile

    cloc --exclude-dir=$excludedDirectories --exclude-ext=$excludedFileExtensions --include-lang=$includedLanguages ./ --by-file --csv --report-file=$slocFile >nul 2>&1
}

generate_change_frequency_report() {
    print_progress_message 'code maat: generating change frequency report - find number of changes for each module to represent effort'
    echo $evolutionFile
    echo $changeFrequencyFile
    maat.bat -l $evolutionFile -c git -a revisions > $changeFrequencyFile
}

perform_hotspot_analysis() {
    print_progress_message 'python: adding hotspots to change frequency report (overlap between complexity & effort)'
    python /c/codemaat/scripts/merge_comp_freqs.py  $changeFrequencyFile $slocFile >nul 2>&1
}

generate_visualisation_json() {
    print_progress_message 'python: generating json for d3 visualisation'
    python /c/codemaat/scripts/csv_as_enclosure_json.py --structure  $slocFile --weights  $changeFrequencyFile --weightcolumn 1 > $visualisationFile
}

copy_visualisation_file_to_destination() {
    print_progress_message 'bash: copying visualisation file to destination'
    cp $visualisationFile $visualisationPath$visualisationFile
}

change_directory_to_visualisation_file_destination() {
    print_progress_message 'bash: changed directory to visualisation file directory'
    cd $visualisationPath
}

start_web_server() {
    print_progress_message 'python: starting local web server on port 8000'
    python -m SimpleHTTPServer 8000
}

analysis_finished() {
    print_progress_message 'bash: analysis complete'
}

clean_old_files
(create_version_control_log)                & spinner $!
(generate_code_maat_summary)                & spinner $!
(generate_line_count_report)                & spinner $!
(generate_change_frequency_report)          & spinner $!
(perform_hotspot_analysis)                  & spinner $!
(generate_visualisation_json)               & spinner $!
(copy_visualisation_file_to_destination)    & spinner $!

analysis_finished
change_directory_to_visualisation_file_destination
start_web_server

