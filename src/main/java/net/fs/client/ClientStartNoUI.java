// Copyright (c) 2015 D1SM.net

package net.fs.client;

import java.io.UnsupportedEncodingException;

public class ClientStartNoUI {

	public static void main(String[] args) {
		try {
			new ClientNoUI();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
	}

}
