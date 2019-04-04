#!/usr/bin/env python3

"""
Copyright (c) 2019 Jared Thibault

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



Title: Journalizer
Author: Jared Thibault
Date: 09-Feb-2019

Description:
    This program will create a journal entry saved into ~/Documents/journalizer/user-specified-folder-name (or what is specified in config file)
    Each entry is a text document with the name yyyy-mm-dd.txt (e.g. 1996-11-29.txt)

<TODO>
    - set up proper execptions
    - expecially when looking at the config_file configparser
</TODO>
"""


import os
import sys
from datetime import date
import subprocess
import argparse
import configparser


# Defines
VERSION = "1.3"
CONFIG_FILE_TEXT = "# IMPORTANT NOTES\n" \
                   "# NOTE 1: This config file is supposed to be located at $HOME/.config/journalizer/config.ini\n" \
                   "# NOTE 2: ~ expansion does not work!\n" \
                   "#     e.g. ~/folder/ is not acceptable!\n" \
                   "#     but $HOME/user/folder/ is acceptable\n" \
                   "#     You should probably fix this at some point\n" \
                   "\n" \
                   "[DEFAULT]\n" \
                   "text_editor = vim\n" \
                   "journals_path = /home/jared/Documents/journalizer/\n"


def main():
    assert ("linux" in sys.platform), "This code runs on Linux only."

    # Creates config file if it doesn't exist
    config_file = os.path.join(os.path.expanduser("~"), ".config", "journalizer", "config.ini")
    if os.path.isfile(config_file) is False:
        create_config_file(config_file)

    # Reads config file and sets up shorthand
    config = setup_config(config_file)
    config_jdir = os.path.expandvars(config["DEFAULT"]["journals_path"])
    config_teditor = config["DEFAULT"]["text_editor"]

    # Reads arguments passed in
    args = setup_argparse()

    # Sets up varibles
    text_editor = setup_text_editor(args.text_editor, config_teditor)
    filename = setup_filename(args.entry)
    directory = setup_directory(args.directory, args.journal, config_jdir)
    file_path = os.path.join(directory, filename)

    # Each function is mutually exclusive
    if args.print is True:
        print_entry(file_path)

    elif args.list_journals is True:
        # Lists journals (directories)
        list_paths(directory, "dirs")

    elif args.list_entries is True:
        # Lists entries (files)
        list_paths(directory, "files")
    
    elif args.create_journal is not None:
        # Creates journals
        for d in args.create_journal:
            create_directory(os.path.join(directory, d))

    elif args.remove is True:
        # Lowest precedence because this could mess things up
        remove_entry(file_path)

    else:
        # Creates entry
        if os.path.isfile(file_path) is False:
            create_jentry(file_path)

        # Actuallly opens entry
        open_jentry(file_path, text_editor)

    sys.exit(0)


def remove_entry(file_path):
    try:
        response = query_yn("Are you sure you want to delete {0}?".format(file_path), "no")
    except ValueError as error:
        print(error)
        sys.exit("internal error!")
    
    if response is False:
        print("Did not delete {0}".format(file_path))
        return
    else:
        try:
            os.remove(file_path) 
        except OSError as error:
            print(error)
            sys.exit("Can't remove file!")

    print("Removed {0}".format(file_path)) 


def query_yn(question, default_answer=None):
    valid_responses = {"yes" : True, "y": True,
             "no": False, "n": False}
    if default_answer is None:
        prompt = " [y/n]"
    elif default_answer == "yes":
        prompt = " [Y/n]"
    elif default_answer == "no":
        prompt = " [y/N]"
    else:
        raise ValueError("default_answer: {0} is invalid".format(default_answer))

    is_exit = False
    while is_exit is False:
        print(question + prompt)
        user_answer = input().lower()

        if default_answer is not None and user_answer == "":
            is_exit = True
            response = valid_responses[default_answer]
        elif user_answer in valid_responses:
            is_exit = True
            response = valid_responses[user_answer]
        else:
            print("Please respond with \'yes\' or \'no\'")

    return response


def print_entry(file_path):
    try:
       with open(file_path, "r") as f:
           for line in f:
               print(line, end='')
    except FileNotFoundError as error:
        print(error)
        sys.exit("File does not exist!")
    except PermissionError as error:
        print(error)
        sys.exit("Can't access file!")


def list_paths(directory, path_type):
    # listdir() returns list of relative paths,
    # NOT full pathnames
    try:
        paths = os.listdir(directory)
    except OSError as error:
        print(error)
        sys.exit("Could not acccess directory!")

    # Need to sort() because listdir() is in arbitrary order
    paths.sort(key=str.lower)

    # Iterates through all paths and finds dirs/files
    path_count = 0
    for path in paths:
        if path_type == "files":
            if os.path.isfile(os.path.join(directory, path)) is True:
                path_count += 1
                print(path)
    
        elif path_type == "dirs":
            if os.path.isdir(os.path.join(directory, path)) is True:
                path_count += 1
                print(path)

    # Displays if it doesn't find any dirs/files
    if path_count == 0:
        if path_type == "files":
            print("No entries found!")
        if path_type == "dirs":
            print("No journals found!")


def create_directory(directory):
    # makrdirs() also creates parent dirs
    try:
        os.makedirs(directory)
    except IOError as error:
        print(error)
        sys.exit("Could not create directory!")


def create_jentry(file_path):
    # Create entry if it doesn't exist
    # permissions: 664
    try:
        # with automatically closes file
        with open(file_path, "w+"):
            pass
    except IOError as error:
        print(error)
        sys.exit("Could not create file!")


def setup_config(config_file):
    # Reads config file
    config = configparser.ConfigParser()
    config.read(config_file)

    return config


def create_config_file(config_file):
    # Creates config file AND config dir
    config_file_text = CONFIG_FILE_TEXT
    try:
        os.makedirs(os.path.dirname(config_file), mode=0o775)
    except IOError as error:
        print(error)
        sys.exit("Could not create directory!")

    try:
        with open(config_file, "w+") as f:
            f.write(config_file_text)
    except IOError as error:
        print(error)
        sys.exit("Could not create file!")
    

def setup_argparse():
    parser = argparse.ArgumentParser(description="Creates and edits journal entries.")

    parser.add_argument("-j", "--journal",
                        help="journal to create file in")

    parser.add_argument("-d", "--directory",
                        help="directory to create file/journal in")

    parser.add_argument("-e", "--entry",
                        help="entry to create/edit")

    parser.add_argument("-t", "--text-editor",
                        help="text editor to use")

    parser.add_argument("-c", "--create-journal",
                        nargs="+",
                        help="create journal(s)")

    parser.add_argument("-l", "--list-entries",
                        action="store_true",
                        help="lists entries in journal/directory")

    parser.add_argument("-L", "--list-journals",
                        action="store_true",
                        help="lists journals in directory (default is config file dir)")
    
    parser.add_argument("-p", "--print",
                        action="store_true",
                        help="displays entry's contents on stdout")

    parser.add_argument("-R", "--remove",
                        action="store_true",
                        help="removes selected entry")

    parser.add_argument("-v", "--version",
                        action="version",
                        version=sys.argv[0] + " " + VERSION)
    
    return parser.parse_args()


def setup_filename(name):
    # Use today's date if not specified
    if name is None:
        filename = str(date.today()) + ".txt"
    else:
        # No ".txt"!
        filename = name 
    
    return filename 


def setup_text_editor(user_teditor, config_teditor):
    # Choose text editor
    if user_teditor is not None:
        # Command-line specified has highest priority
        text_editor = user_teditor
    elif config_teditor != "":
        # ...Then config file specified
        text_editor = config_teditor
    else:
        # ...Then OS default
        text_editor = "xdg-open"

    return text_editor


def setup_directory(user_dir, user_journal, config_jdir):
    # Chooses which directory to use

    # <TODO>
    # make ".." expand recursively (like with cd ../../..)
    #</TODO>

    # CLI directory (-d) takes highest priority
    if user_dir is not None:
        # Manually do '.' expansion
        if user_dir == ".":
            user_dir = os.getcwd()

        # Append the journal name to the directory, if there is one
        if user_journal is None:
            directory = user_dir
        else:
            directory = os.path.join(user_dir, user_journal)

    # ...Then config file directory
    elif user_journal is None:
        directory = config_jdir

    # ...Then config file dir + journal dir
    elif config_jdir != "":
        # Expand variables in config file
        directory = os.path.expandvars(os.path.join(config_jdir, user_journal))

    # ...Then current directory
    else:
        directory = os.getcwd()

    return directory 


def open_jentry(file_path, text_editor):
    # Open entry with text editor
    try:
        subprocess.run((text_editor, file_path))
    except FileNotFoundError as error:
        print(error)
        sys.exit("Text editor does not exist!")
    except PermissionError as error:
        print(error)
        sys.exit("Can't access file!")


if __name__ == "__main__":
    main()
