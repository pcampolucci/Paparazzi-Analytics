"""
Title: Converter .data to .csv
Description: The script takes one message at a time and converts it to .csv for better handling
Author: Pietro Campolucci
"""

# import packages
from os import walk
from bs4 import BeautifulSoup
import os
import pandas as pd
from tqdm import tqdm
from termcolor import colored
import numpy as np


class Converter:

    def __init__(self, message):
        self.body = BeautifulSoup(self.read_data(), "xml")
        self.path = os.getcwd()
        self.msg = message
        self.conv_library = self.get_conv_library()  # list of names of the already converted files
        self.raw_library = self.get_raw_library()  # list of names of the raw files

    @staticmethod
    def read_data():

        with open('messages.xml', 'r') as f:
            data = f.read()

        return data

    def get_msg_list(self):

        msg_list = []

        for i in self.body.find_all("message"):
            msg_list.append(i["name"])

        return msg_list

    def get_item_msg(self):

        item_lst = []

        for i in self.body.find('message', {'name': self.msg}).find_all("field"):
            item_lst.append(i["name"])

        return item_lst

    def get_conv_library(self):
        conv_lib = []

        for (dirpath, dirnames, filenames) in walk(f"{self.path}/logs_converted"):
            for file in filenames:
                if file[0] != "~":
                    conv_lib.append(file[:-4])
            break

        return conv_lib

    def get_raw_library(self):

        raw_lib = []

        for (dirpath, dirnames, filenames) in walk(f"{self.path}/logs_raw"):
            data_path = []
            for file in filenames:
                if file[-5:] == ".data":
                    data_path.append(file)
            raw_lib.extend(data_path)
            break

        return raw_lib

    def convert(self):

        for name in self.raw_library:
            data_name_w_msg = name[:-5] + f"_{self.msg}"
            data_name = name[:-5]
            if data_name_w_msg not in self.conv_library:
                print(colored(f"{data_name_w_msg}: File to be converted. Conversion started ...", 'blue'))
                self.logs_reader(data_name)
            else:
                print(colored(f"{data_name_w_msg}: File already converted! Ignoring ...", 'yellow'))

    def logs_reader(self, filename):
        """ This function reads the data file and gives a dataframe of the values"""

        # path and dataframe build
        file_name = filename
        log_path = self.path + "/logs_raw/" + file_name + ".data"
        msg_list = self.get_item_msg()
        df = pd.DataFrame(columns=msg_list)
        datafile = open(log_path, "r")

        # parse data file and append
        for data in tqdm(datafile, f"{filename}"):
            data_split = data.split(" ")
            data_sensor = data_split[2]
            data_payload = data_split[3:]
            if data_sensor == self.msg:
                df_row = np.zeros(len(msg_list))
                for value in range(len(msg_list)):
                    df_row[value] = float(data_payload[value])

                df.loc[-1] = df_row
                df.index += 1
                df = df.sort_index()

        # write dataframe to csv for storage
        df.to_csv(f"{self.path}/logs_converted/{filename}_{self.msg}.csv")
        print(colored(f"File written to {self.path}/logs_converted/{filename}_{self.msg}.csv", 'green'))

        return df


