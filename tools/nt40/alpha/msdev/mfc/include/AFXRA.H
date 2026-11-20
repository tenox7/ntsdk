// This is a part of the Microsoft Foundation Classes C++ library.
// Copyright (C) 1992-1995 Microsoft Corporation
// All rights reserved.
//
// This source code is only intended as a supplement to the
// Microsoft Foundation Classes Reference and related
// electronic documentation provided with the library.
// See these sources for detailed information regarding the
// Microsoft Foundation Classes product.

#ifndef __AFXRA_H__
#define __AFXRA_H__

#ifdef _AFX_NO_OLERA_SUPPORT
	#error OLE Remote Automation classes not supported in this library variant.
#endif

#ifndef __AFX_H__
#include <afx.h>
#endif

#ifndef __AFXWIN_H__
#include <afxwin.h>
#endif

#ifdef _AFX_MINREBUILD
#pragma component(minrebuild, off)
#endif
#ifndef _AFX_FULLTYPEINFO
#pragma component(mintypeinfo, on)
#endif

#ifndef _AFX_NOFORCE_LIBS
#pragma comment(lib, "ole32.lib")
#endif

#ifdef _AFX_PACKING
#pragma pack(push, _AFX_PACKING)
#endif

/////////////////////////////////////////////////////////////////////////////
// AFXRA.H - MFC OLE Remote Automation support

// Classes declared in this file

//CRemoteAutomationSettings		// Implementation
	class CRemoteClientSettings;	// Client side RA settings
	class CRemoteServerSettings;	// Server side RA settings

/////////////////////////////////////////////////////////////////////////////

// AFXDLL support
#undef AFX_DATA
#define AFX_DATA AFX_OLE_DATA

/////////////////////////////////////////////////////////////////////////////
// CRemoteAutomationSettings -- Implementation

class CRemoteAutoSettings
{
// Constructors
public:
	CRemoteAutoSettings(REFCLSID rclsid);
	CRemoteAutoSettings(LPCTSTR lpszProgID);

// Attributes
public:
	CString GetCLSID() const;

// Operations
public:
	void SetCLSID(REFCLSID rclsid);
	void SetCLSID(LPCTSTR lpszProgID);

// Implementation
public:
	~CRemoteAutoSettings();
	HKEY OpenCLSIDKey() const;
protected:
	CString m_strClsid;
};

/////////////////////////////////////////////////////////////////////////////
// CRemoteServerSettings -- Server side Remote Automation settings

class CRemoteServerSettings : public CRemoteAutoSettings
{
// System policy

// Attributes
public:

	enum ActivationPolicies
	{	policyNone = 0,	// Disallow all remote automation
		policyAll = 1,	// Allow all remote automation
		policyByKey = 2,// Allow remote automation of classes with subkey
		policyByAcl = 3,// Allow remote automation of classes with NT security
		policyError = 0xFFFFFFFF};

// Operations
public:
	static UINT ReadActivationPolicy();
	static BOOL WriteActivationPolicy(UINT nPolicy);

// Class policy

// Attributes
public:
	BOOL m_bActivateByKey;
	using CRemoteAutoSettings::GetCLSID;

// Constructors
public:
	CRemoteServerSettings(REFCLSID rclsid);
	CRemoteServerSettings(LPCTSTR lpszProgID);

// Operations
public:
	BOOL ReadSettings();
	BOOL WriteSettings();
	using CRemoteAutoSettings::SetCLSID;
	
// Implementation
public:
	~CRemoteServerSettings();
};

/////////////////////////////////////////////////////////////////////////////
// CRemoteClientSettings -- Client side Remote Automation settings

class CRemoteClientSettings : public CRemoteAutoSettings
{
// Attributes
public:
	enum Protocols
	{	protMin = 0,
		protTCPIP = 0,		// ncacn_ip_tcp	TCP/IP
		protNetBEUI = 1,	// ncacn_nb_nb	NetBEUI over NetBIOS
		protTCPoverNB = 2,	// ncacn_nb_tcp	TCP/IP over NetBIOS
		protPipes = 3,		// ncacn_np		Named Pipes
		protSPX = 4,		// ncacn_spx	Connection-oriented SPX
		protDG_TCPIP = 5,	// ncadg_ip_udp	Datagram-oriented TCP/IP
		protDG_IPX = 6,		// ncadg_ipx	Datagram-oriented IPX
		protIPXoverNB = 7,	// ncacn_nb_ipx	IPX over NetBIOS
		protMax = 8,
		protEmpty = 0xFFFFFFFF,
		protUnknown = 0xFFFFFFFF};

	enum AuthenticationLevels
	{	authMin = 0,
		authDefault = 0,	// Use network default.
		authNone = 1,		// No authentication.
		authConnect = 2,	// Connection to the server is authenticated
		authCall = 3,		// Authenticates only at the beginning of each
							// remote procedure call, when the server
							// receives the request. Does not apply to
							// connection-based protocol sequences (those
							// that start with the prefix "ncacn").
		authPacket = 4,		// Verifies that all data received is from the
							// expected client.
		authPacketIntegrity = 5,// Verifies that none of the data transferred
								// between client and server has been modified.
		authPacketPrivacy = 6,	// Verifies all previous levels, and encrypts
								// the argument values of each remote procedure call.
		authMax = 7,
		authEmpty = 0xFFFFFFFF,
		authUnknown = 0xFFFFFFFF};

	BOOL m_bIsRemoted;
	CString m_strNetworkAddress;

	UINT GetProtocolSequence() const;
	UINT GetAuthenticationLevel() const;
	using CRemoteAutoSettings::GetCLSID;

// Constructors
public:
	CRemoteClientSettings(REFCLSID rclsid);
	CRemoteClientSettings(LPCTSTR lpszProgID);

// Operations
public:
	BOOL SetProtocolSequence(UINT nPS);
	BOOL SetAuthenticationLevel(UINT nAL);
	BOOL ReadSettings();
	BOOL WriteSettings();
	using CRemoteAutoSettings::SetCLSID;

// Implementation
public:
	CString m_strProtocolSequence;
	CString m_strAuthenticationLevel;
	~CRemoteClientSettings();
};

#ifdef _AFX_PACKING
#pragma pack(pop)
#endif

#undef AFX_DATA
#define AFX_DATA

#ifdef _AFX_MINREBUILD
#pragma component(minrebuild, on)
#endif
#ifndef _AFX_FULLTYPEINFO
#pragma component(mintypeinfo, off)
#endif

#endif //__AFXRA_H__

/////////////////////////////////////////////////////////////////////////////
