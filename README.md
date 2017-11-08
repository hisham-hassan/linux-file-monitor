# linux-file-monitor
A script that monitors all the changes done on a specific file, while keeping all the changes history. the script depends on the inotifywait and git packages being installed.  
```
Usage: file-monitor.sh [-f|--file] <absolute-file-path> [-m|--monitor|-h|--history]  
       file-monitor.sh --help  

 -f,--file <absolute-file-path>	Adding a file to the monitored files List. The <absolute-file-path>  
                                is the absolute file path of the file we need to action.  
                                PLEASE NOTE: Relative file path could cause issues in the script,  
                                please make sure to use the abolute path of the file. also try to   
                                avoid sym links, as it has not been tested.  
                                example: file-monitor.sh -f /absolute/path/to/file/test.txt -m  
 -m, --monitor                  Monitoring all the changes on the file. the monitoring will keep  
                                happening as long as the script is running; you may need to run it  
                                in the background.  
                                example: file-monitor.sh -f /absolute/path/to/file/test.txt -m  
 -h, --history                  showing the full history of the file.  
                                To exit, press "q"  
                                example: file-monitor.sh -f /absolute/path/to/file/test.txt -h  
 --uninstall                    uninstalls the script from the bin direcotry,  
                                and removes the monitoring history.  
 --install                      Adds the script to the bin directory, and creates  
                                the directories and files needed for monitoring.  
 --help                         Prints this help message.  
  ```
