# -*- coding: utf-8 -*-
"""Base test module."""

import unittest
from unittest.mock import patch


class BaseTestCase(unittest.TestCase):
    def setUp(self):
        super(BaseTestCase, self).setUp()
        self.addCleanup(patch.stopall)
