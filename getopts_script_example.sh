#!/usr/bin/env bash
blastfile=
comparefile=
referencegenome=
referenceCDS=

help='''
  USAGE:   sh lincRNA_pipeline.sh
    -c   </path/to/cuffcompare_output file>
    -g   </path/to/reference genome file>
    -r   </path/to/reference CDS file>
    -b   </path/to/RNA file>
'''

while getopts ":b:c:g:hr:" opt; do
    ## Count the opts
    let optnum++
    case $opt in
        b)
            blastfile=$OPTARG
            echo "$blastfile"
            ;;
        c)
            comparefile=$OPTARG
            ;;
        h)
            printf "$help"
            exit 1
            ;;
        g)
            referencegenome=$OPTARG
            ;;
        r)
            referenceCDS=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

[[ $opts -lt 3 ]] && echo "At least 3 parameters must be given"
