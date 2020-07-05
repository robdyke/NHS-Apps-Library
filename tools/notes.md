# Notes

```sh
robd@nuc:~/NHS-Apps-Library/tools$ ./appsummary.sh 
INFO: appsummary.sh
    ./appsummary.sh -i -m -c -t -f -s APPNAME
    ./appsummary.sh --list
    ./appsummary.sh --report APPNAME SCANHASH
    ./appsummary.sh --summary APPNAME
    ./appsummary.sh --all-report --all-summary --all-trackers --all-output
    ./appsummary.sh --test
```

```sh
robd@nuc:~/NHS-Apps-Library/tools$ OUTDIR=tmp TOKEN=45a5ac0c6084ec1293b7574623f45da889d77da3e5dd772fc828bedfa66e6221 ./appsummary.sh --test
TEST: SCRIPT_DIR is /home/robd/projects/apps/NHS-Apps-Library/tools
TEST: ROOT_DIR is /home/robd/projects/apps/NHS-Apps-Library
TEST: MobSF API token is 45a5ac0c6084ec1293b7574623f45da889d77da3e5dd772fc828bedfa66e6221
TEST: Output directory is tmp
```

'python mass_static_analysis.py -s 127.0.0.1:8000  -k <rest_api_key> -d /home/files/'

'robd@nuc:~/Mobile-Security-Framework-MobSF/scripts$ python3.6 mass_static_analysis.py -s 127.0.0.1:8000  -k 45a5ac0c6084ec1293b7574623f45da889d77da3e5dd772fc828bedfa66e6221 -d /home/robd/projects/apps/NHS-Apps-Library/APKS -r 1'

