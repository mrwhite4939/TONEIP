#!/bin/bash

# ToneIP v2.5 - IP Geolocation Tool
# By MrWhite4939

R="\033[91m"; G="\033[92m"; Y="\033[93m"; B="\033[94m"; M="\033[95m"; C="\033[96m"; W="\033[97m"; D="\033[2m"; BD="\033[1m"; RT="\033[0m"

API="http://ip-api.com/json"
TIMEOUT=10
DIR="$HOME/.toneip"
RESULTS="$DIR/results.txt"
HISTORY="$DIR/history.txt"

[[ ! -d "$DIR" ]] && mkdir -p "$DIR"
[[ ! -f "$RESULTS" ]] && touch "$RESULTS"
[[ ! -f "$HISTORY" ]] && touch "$HISTORY"

valid_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            [[ $i -gt 255 ]] && return 1
        done
        return 0
    fi
    return 1
}

parse() {
    echo "$1" | grep -oP "(?<=\"$2\":)[^,}]*" | tr -d '"' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | head -n1
}

banner() {
    clear
    echo -e "${C}${BD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ████████╗ ██████╗ ███╗   ██╗███████╗██╗██████╗             ║"
    echo "║  ╚══██╔══╝██╔═══██╗████╗  ██║██╔════╝██║██╔══██╗            ║"
    echo "║     ██║   ██║   ██║██╔██╗ ██║█████╗  ██║██████╔╝            ║"
    echo "║     ██║   ██║   ██║██║╚██╗██║██╔══╝  ██║██╔═══╝             ║"
    echo "║     ██║   ╚██████╔╝██║ ╚████║███████╗██║██║                 ║"
    echo "║     ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝╚═╝                 ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${RT}"
    echo -e "${M}${BD}        🌐 IP Geolocation Intelligence Tool 🌐${RT}"
    echo -e "${D}                   Version 2.5${RT}"
    echo -e "${D}                By MrWhite4939${RT}\n"
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RT}\n"
}

menu() {
    echo -e "${M}${BD}╭─────────────── MAIN MENU ───────────────╮${RT}"
    echo -e "${M}│${RT}                                          ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[1]${RT} ${C}→${RT} ${W}Show My IP${RT}                     ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[2]${RT} ${C}→${RT} ${W}Track IP Address${RT}               ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[3]${RT} ${C}→${RT} ${W}Batch IP Lookup${RT}                ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[4]${RT} ${C}→${RT} ${W}View History${RT}                   ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[5]${RT} ${C}→${RT} ${W}Export Results${RT}                 ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[6]${RT} ${C}→${RT} ${W}Clear Data${RT}                     ${M}│${RT}"
    echo -e "${M}│${RT}  ${Y}[0]${RT} ${C}→${RT} ${W}Exit${RT}                           ${M}│${RT}"
    echo -e "${M}│${RT}                                          ${M}│${RT}"
    echo -e "${M}╰──────────────────────────────────────────╯${RT}\n"
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RT}"
    
    while true; do
        read -p "$(echo -e ${Y}${BD}Option:${RT} )" opt
        
        case $opt in
            1) my_ip; return ;;
            2) track_ip; return ;;
            3) batch; return ;;
            4) view_history; return ;;
            5) export_results; return ;;
            6) clear_data; return ;;
            0) bye; return ;;
            "") 
                echo -e "${R}Please enter a number${RT}"
                continue
                ;;
            *) 
                echo -e "${R}Invalid option! Choose 0-6${RT}"
                continue
                ;;
        esac
    done
}

show_info() {
    local d="$1"
    local s=$(parse "$d" "status")
    
    if [[ "$s" != "success" ]]; then
        echo -e "\n${R}${BD}✗ Error: Unable to get data${RT}"
        return 1
    fi
    
    local ip=$(parse "$d" "query")
    local city=$(parse "$d" "city")
    local region=$(parse "$d" "regionName")
    local country=$(parse "$d" "country")
    local cc=$(parse "$d" "countryCode")
    local isp=$(parse "$d" "isp")
    local org=$(parse "$d" "org")
    local asn=$(parse "$d" "as")
    local lat=$(parse "$d" "lat")
    local lon=$(parse "$d" "lon")
    local tz=$(parse "$d" "timezone")
    local zip=$(parse "$d" "zip")
    
    echo -e "\n${C}${BD}╔═════════════════════════════════════════════════════╗${RT}"
    echo -e "${C}${BD}║           🌍 LOCATION DETAILS 🌍                    ║${RT}"
    echo -e "${C}${BD}╚═════════════════════════════════════════════════════╝${RT}\n"
    
    echo -e "${M}${BD}┌─ Basic Info ──────────────────────────┐${RT}"
    echo -e "${C}│${RT} ${W}IP Address:${RT}      ${BD}$ip${RT}"
    echo -e "${C}│${RT} ${W}Status:${RT}          ${G}✓ Active${RT}"
    echo -e "${M}└───────────────────────────────────────┘${RT}\n"
    
    echo -e "${M}${BD}┌─ Location ────────────────────────────┐${RT}"
    echo -e "${C}│${RT} ${W}Country:${RT}         $country ($cc)"
    echo -e "${C}│${RT} ${W}Region:${RT}          ${region:-N/A}"
    echo -e "${C}│${RT} ${W}City:${RT}            ${city:-N/A}"
    echo -e "${C}│${RT} ${W}ZIP Code:${RT}        ${zip:-N/A}"
    echo -e "${C}│${RT} ${W}Timezone:${RT}        ${tz:-N/A}"
    echo -e "${M}└───────────────────────────────────────┘${RT}\n"
    
    echo -e "${M}${BD}┌─ Network ─────────────────────────────┐${RT}"
    echo -e "${C}│${RT} ${W}ISP:${RT}             ${isp:-N/A}"
    echo -e "${C}│${RT} ${W}Organization:${RT}    ${org:-N/A}"
    echo -e "${C}│${RT} ${W}ASN:${RT}             ${asn:-N/A}"
    echo -e "${M}└───────────────────────────────────────┘${RT}\n"
    
    echo -e "${M}${BD}┌─ Coordinates ─────────────────────────┐${RT}"
    echo -e "${C}│${RT} ${W}Latitude:${RT}        $lat"
    echo -e "${C}│${RT} ${W}Longitude:${RT}       $lon"
    [[ -n "$lat" && -n "$lon" ]] && {
        echo -e "${C}│${RT} ${W}Google Maps:${RT}"
        echo -e "${C}│${RT} ${B}https://maps.google.com/?q=$lat,$lon${RT}"
    }
    echo -e "${M}└───────────────────────────────────────┘${RT}\n"
    
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] $ip - $country ($city)" >> "$HISTORY"
    echo "═══════════════════════════════════════" >> "$RESULTS"
    echo "Time: $ts" >> "$RESULTS"
    echo "IP: $ip" >> "$RESULTS"
    echo "Location: $city, $region, $country" >> "$RESULTS"
    echo "ISP: $isp" >> "$RESULTS"
    echo "Coordinates: $lat, $lon" >> "$RESULTS"
    echo "Map: https://maps.google.com/?q=$lat,$lon" >> "$RESULTS"
    echo "═══════════════════════════════════════" >> "$RESULTS"
    echo "" >> "$RESULTS"
    
    echo -e "${G}✓${RT} ${D}Saved by MrWhite4939${RT}"
    return 0
}

fetch() {
    local ip="$1"
    local url="${API}/${ip}"
    curl -s --max-time "$TIMEOUT" "$url" 2>/dev/null
}

my_ip() {
    banner
    echo -e "${Y}⟳ Fetching your IP...${RT}\n"
    local d=$(fetch "")
    if [[ -z "$d" ]]; then
        echo -e "${R}Connection failed!${RT}\n"
    else
        show_info "$d"
    fi
    nav
}

track_ip() {
    banner
    echo -e "${Y}${BD}Track IP Address${RT}\n"
    
    while true; do
        read -p "$(echo -e ${C}IP:${RT} )" ip
        
        if [[ -z "$ip" ]]; then
            echo -e "${Y}Cancelled${RT}"
            sleep 1
            banner
            menu
            return
        fi
        
        if ! valid_ip "$ip"; then
            echo -e "${R}Invalid IP format! Try again${RT}"
            continue
        fi
        
        break
    done
    
    echo -e "\n${Y}⟳ Tracking $ip...${RT}\n"
    local d=$(fetch "$ip")
    if [[ -z "$d" ]]; then
        echo -e "${R}Failed!${RT}\n"
    else
        show_info "$d"
    fi
    nav
}

batch() {
    banner
    echo -e "${Y}${BD}Batch IP Lookup${RT}\n"
    echo -e "${D}Enter IPs (press Enter twice to finish):${RT}\n"
    
    local ips=()
    local empty_count=0
    
    while true; do
        read -p "$(echo -e ${C}IP:${RT} )" inp
        
        if [[ -z "$inp" ]]; then
            ((empty_count++))
            if [[ $empty_count -ge 2 ]]; then
                break
            fi
            continue
        fi
        
        empty_count=0
        
        if valid_ip "$inp"; then
            ips+=("$inp")
            echo -e "${G}✓ $inp${RT}"
        else
            echo -e "${R}✗ $inp (invalid)${RT}"
        fi
    done
    
    if [[ ${#ips[@]} -eq 0 ]]; then
        echo -e "${Y}No valid IPs entered${RT}"
        sleep 2
        banner
        menu
        return
    fi
    
    echo -e "\n${C}Processing ${#ips[@]} IP(s)...${RT}\n"
    
    for ip in "${ips[@]}"; do
        echo -e "${M}━━━ $ip ━━━${RT}"
        local d=$(fetch "$ip")
        if [[ -n "$d" ]]; then
            show_info "$d"
        fi
        echo ""
        sleep 0.3
    done
    
    echo -e "${G}Done!${RT}\n"
    nav
}

view_history() {
    banner
    echo -e "${Y}${BD}Search History${RT}\n"
    
    if [[ ! -s "$HISTORY" ]]; then
        echo -e "${Y}No history available${RT}\n"
    else
        echo -e "${C}Recent (last 20):${RT}\n"
        tail -20 "$HISTORY"
        echo ""
    fi
    nav
}

export_results() {
    banner
    echo -e "${Y}${BD}Export Results${RT}\n"
    
    if [[ ! -s "$RESULTS" ]]; then
        echo -e "${Y}No results to export${RT}\n"
        nav
        return
    fi
    
    local f="toneip_$(date '+%Y%m%d_%H%M%S').txt"
    cp "$RESULTS" "$f"
    echo -e "${G}✓ Exported by MrWhite4939!${RT}\n"
    echo -e "${C}File: $f${RT}\n"
    nav
}

clear_data() {
    banner
    echo -e "${R}${BD}⚠ Clear All Data?${RT}\n"
    
    while true; do
        read -p "$(echo -e ${R}Type 'yes' to confirm:${RT} )" ans
        
        if [[ "$ans" == "yes" ]]; then
            rm -f "$RESULTS" "$HISTORY"
            touch "$RESULTS" "$HISTORY"
            echo -e "\n${G}✓ Cleared!${RT}\n"
            sleep 1
            banner
            menu
            return
        elif [[ -n "$ans" ]]; then
            echo -e "\n${C}Cancelled${RT}\n"
            sleep 1
            banner
            menu
            return
        fi
    done
}

nav() {
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RT}"
    
    while true; do
        read -p "$(echo -e ${Y}${BD}[M] Menu  [E] Exit:${RT} )" n
        
        case "${n,,}" in
            m|menu) 
                banner
                menu
                return
                ;;
            e|exit) 
                bye
                return
                ;;
            "") 
                echo -e "${R}Please enter M or E${RT}"
                continue
                ;;
            *) 
                echo -e "${R}Invalid! Enter M or E${RT}"
                continue
                ;;
        esac
    done
}

bye() {
    clear
    echo -e "\n${C}${BD}╔═══════════════════════════════════════════════════╗${RT}"
    echo -e "${C}${BD}║                                                   ║${RT}"
    echo -e "${C}${BD}║          Thank you for using ToneIP! 🌐          ║${RT}"
    echo -e "${C}${BD}║              Created by MrWhite4939              ║${RT}"
    echo -e "${C}${BD}║                Stay secure! 🛡️                   ║${RT}"
    echo -e "${C}${BD}║                                                   ║${RT}"
    echo -e "${C}${BD}╚═══════════════════════════════════════════════════╝${RT}\n"
    exit 0
}

banner
menu