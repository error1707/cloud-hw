#!/bin/zsh

zip -j terraform/validate_input validate_input/*
zip -j terraform/style_transfer style_transfer/*
zip -j terraform/create_task create_task/*
zip -j terraform/list_tasks list_tasks/*
zip -j terraform/get_task get_task/*