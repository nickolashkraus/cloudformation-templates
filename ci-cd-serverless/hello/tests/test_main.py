#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Tests for the `main` module."""

from hello import main

from .base import BaseTestCase


class MainTestCase(BaseTestCase):
    def test_handler(self):
        expected = 'Hello, World!'
        actual = main.handler({}, None)
        self.assertEqual(expected, actual)
