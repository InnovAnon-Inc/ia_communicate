#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" REST Helper """

import asyncio
from functools                               import cached_property
import gzip
import os
from pathlib                                 import Path
import shutil
import time
from typing                                  import Iterator
from typing                                  import List
from typing                                  import List, Tuple

import dotenv
from httpx                                   import AsyncClient
from httpx                                   import ConnectError
from httpx                                   import ConnectTimeout
from httpx                                   import Limits
from httpx                                   import ProtocolError
from httpx                                   import ReadError
from httpx                                   import ReadTimeout
from httpx                                   import RemoteProtocolError
from httpx                                   import WriteError
from httpx                                   import WriteTimeout
from retry_async                             import retry
from structlog                               import get_logger

logger = get_logger()

class CommunicateError(Exception):
	""" Unexpected Status Code """

@retry((
	ConnectError,
	ConnectTimeout,
	ProtocolError,
	ReadError,
	ReadTimeout,
	RemoteProtocolError,
	WriteError,
	WriteTimeout,
), tries=None, delay=1, backoff=2, max_delay=None, is_async=True)
async def communicate(client:AsyncClient, url:str, message:str, uid:str,)->str:
	params  :Dict[str,str] = {
		'message': message,
		'client' : uid,
	}
	#response               = await client.get(url, params=params, timeout=None,) # TODO 600 ?
	response               = await client.get(url, params=params,)
	if (response.status_code != 200):
		await logger.awarn('status code: %s', response.status_code,)
		#return None
		raise CommunicateError(str(response.status_code))
	content :bytes         = response.content
	result  :str           = content.decode('utf-8')
	await logger.ainfo('response: %s', result,)
	return result

def get_limits(
	max_connections          :int    = 10,
	max_keepalive_connections:int    =  5,
)->Limits:
	return Limits(
		max_connections          =max_connections,
		max_keepalive_connections=max_keepalive_connections,)

def main()->None:
	# TODO
	pass

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
