#!/bin/bash
MYEOF=E_O_F

# Add '/' at the end of path string
pathfix()
{
    if [ ! "/" = "${1:0-1}" ]; then
        echo "${1}/"
    else
        echo "$1"
    fi
}

##################
# Get Env values #
##################
# path of where i am
BASEPATH=$(cd `dirname $0`; pwd)
BASEPATH=`pathfix $BASEPATH`

# cfg file path
CFGFILE="${BASEPATH}recipe.conf"

# configs from cfg file
if [ ! -f $CFGFILE ]; then
    echo "Config file dose NOT exist!" 1>&2
    echo "Please create it with the name: recipe.conf" 1>&2
    exit -1
fi

# read all cfgs from cfg file
while read MYLINE; do
    if [ "#" = "${MYLINE:0:1}" ]; then
        continue
    fi
    if [ 0 -eq ${#MYLINE} ]; then
        continue
    fi
    eval ${MYLINE%%:*}=${MYLINE#*:}
done << $MYEOF
    `cat $CFGFILE | sed s/[[:space:]]//g`
$MYEOF

do_new_draft()
{
    if [ 0 -eq ${#CFGHEXOMYSOURCE} ]; then
        echo "Error: CFGHEXOBLOGPATH is NOT set, please set it up in recipe.conf." >&2
        return
    fi
    cd $BASEPATH > /dev/null
    if [ ! -d "$CFGHEXOMYSOURCE" ]; then
        echo "Error: Please creat your blog folder in up menu => 'Mysource management'." >&2
        return
    fi
    local mypath=`pathfix $(cd $CFGHEXOMYSOURCE; pwd)`
    local drpath="${mypath}_drafts/"
	local popath="${mypath}_posts/"
    local ymname=`date "+%Y%m"`

    if [ ! -d "${drpath}${ymname}" ]; then
		mkdir -p "${drpath}${ymname}"
	fi
	if [ ! -d "${popath}${ymname}" ]; then
		mkdir -p "${popath}${ymname}"
	fi

    local fn=""
	local tmpstr=`ls ${popath}${ymname} ${drpath}${ymname} 2> /dev/null | grep .*\.md | sort -r | head -1`

    if [ 0 -eq ${#tmpstr} ]; then
		# first post of current month
		fn=`date "+%Y-%m-%d.001.md"`
    else
        tmpstr=${tmpstr: 11: 3}
        if [ "$tmpstr" = "999" ]; then
			echo "Error: Too many posts a month! 999 is the max." 1>&2
			return
		fi
        ((tmpstr=10#$tmpstr+1))
        if [ $tmpstr -lt 10 ]; then
			fn=`date "+%Y-%m-%d.00${tmpstr}.md"`
		elif [ $tmpstr -lt 100 ]; then
			fn=`date "+%Y-%m-%d.0${tmpstr}.md"`
		else
			fn=`date "+%Y-%m-%d.${tmpstr}.md"`
		fi
    fi

    # create the post
	cat > ${drpath}${ymname}/${fn} << $MYEOF
---
title: title place for you!
date: `date "+%Y-%m-%d %H:%M:%S"`
tags:
---
$MYEOF
  echo "Info: New draft created! File Name: $fn"
}

# Menu 4
menu_myblog()
{
    while [ 0 ] ; do
        echo "You can manage your draft or post here."
        select MYSEL in \
            "New draft" \
            "Move article to post" \
            "Move article to draft" \
            "Delete draft" \
            "Clear empty folders" \
            "Back" \
        ; do
            case $REPLY in
                1) do_new_draft ;;
                2) : ;;
                3) : ;;
                4) : ;;
                5) : ;;
                6) : ;;
            esac
            break
        done
        if [ $REPLY -eq 6 ]; then
            break
        fi
    done
}

# test
do_new_draft

# Main menu
: << $MYEOF
while [ 0 ] ; do
    echo "THis is a hexo blog helper. Select what you want:"
    select MYSEL in \
        "Hexo environment" \
        "Mysouce management" \
        "Server action" \
        "Myblog management" \
        "Exit" \
    ; do
        case $REPLY in
            1) : ;;
            2) : ;;
            3) : ;;
            4) menu_myblog ;;
            5) : ;;
        esac
        break
    done
    if [ $REPLY -eq 5 ]; then
        break
    fi
done
$MYEOF

