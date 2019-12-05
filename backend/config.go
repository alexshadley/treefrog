package main

import (
	"errors"
	"io/ioutil"
	"encoding/json"
)

type Config struct {
	DbUsername string
	DbPassword string
	Database string
	DbUrl string
}

func LoadConfig() (Config, error) {
	content, err1 := ioutil.ReadFile("config.json")
	sample_content, err2 := ioutil.ReadFile("sample_config.json")

	if err1 != nil && err2 != nil {
		return Config{}, errors.New("No config file found")
	} else if err1 != nil && err2 == nil {
		content = sample_content
	}

	config := Config{}
	err := json.Unmarshal(content, &config)
	return config, err
}